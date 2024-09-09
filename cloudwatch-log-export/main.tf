locals {
  has_destination_bucket = (var.destination_bucket != "") && (var.destination_bucket != null)
  destination_bucket     = local.has_destination_bucket ? var.destination_bucket : "${var.name_prefix}-s3-bucket-cloudwatch-logs"
  destination_bucket_arn = "arn:aws:s3:::${local.destination_bucket}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "cloudwatch_logs_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  create_bucket = var.create && var.create_destination_bucket
  bucket        = local.destination_bucket

  versioning = {
    status     = true
    mfa_delete = false
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  object_ownership        = "BucketOwnerEnforced"
  lifecycle_rule          = var.destination_bucket_lifecycle_policy

  tags = var.tags
}

module "firehose_to_s3_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.44.0"

  create_role = var.create
  role_name   = "${var.name_prefix}-iam-role-fhds-log-exporter"

  trusted_role_services = ["firehose.amazonaws.com"]
  role_requires_mfa     = false
  inline_policy_statements = [{
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      local.destination_bucket_arn,
      "${local.destination_bucket_arn}/*",
    ]
  }]
  tags = var.tags
}

resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_log_exporter" {
  count       = var.create ? 1 : 0
  name        = "${var.name_prefix}-fhds-cloudwatch-log-exporter"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = module.firehose_to_s3_role.iam_role_arn
    bucket_arn = local.destination_bucket_arn

    buffering_size     = 64
    buffering_interval = 600
    file_extension     = ".jsonl"

    dynamic_partitioning_configuration {
      enabled = "true"
    }

    prefix              = var.destination_bucket_prefix
    error_output_prefix = var.destination_bucket_error_prefix

    processing_configuration {
      enabled = "true"
      processors {
        type = "MetadataExtraction"
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{log_group:.logGroup,log_stream:.logStream}"
        }
      }
      processors {
        type = "Decompression"
        parameters {
          parameter_name  = "CompressionFormat"
          parameter_value = "GZIP"
        }
      }
      processors {
        type = "AppendDelimiterToRecord"
      }
    }
  }
  tags = var.tags
}

data "aws_iam_policy_document" "cloudwatch_to_firehose_trust_policy" {
  count = var.create ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
    principals {
      identifiers = ["logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

module "cloudwatch_to_firehose_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.44.0"

  create_role = var.create
  role_name   = "${var.name_prefix}-iam-role-cloudwatch-log-exporter"

  role_requires_mfa               = false
  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.cloudwatch_to_firehose_trust_policy[0].json

  inline_policy_statements = [{
    effect    = "Allow"
    actions   = ["firehose:PutRecord"]
    resources = [aws_kinesis_firehose_delivery_stream.cloudwatch_log_exporter[0].arn]
  }]
  tags = var.tags
}

resource "aws_cloudwatch_log_account_policy" "cloudwatch_log_exporter" {
  count       = var.create ? 1 : 0
  policy_name = "${var.name_prefix}-cloudwatch-log-account-policy-exporter"
  policy_type = "SUBSCRIPTION_FILTER_POLICY"
  policy_document = jsonencode({
    DestinationArn = aws_kinesis_firehose_delivery_stream.cloudwatch_log_exporter[0].arn
    RoleArn        = module.cloudwatch_to_firehose_role.iam_role_arn
    FilterPattern  = ""
  })
}
