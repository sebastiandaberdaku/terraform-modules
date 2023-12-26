module "prefix_and_tags" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//prefix-and-tags"

  company     = var.company
  environment = var.environment
  team        = var.team
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

module "s3_backend" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//aws-s3-bucket"

  company     = var.company
  environment = var.environment
  team        = var.team

  bucket = var.s3_bucket_name
  versioning = {
    status     = true
    mfa_delete = false
  }
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "dynamodb_table_lock" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//aws-dynamodb-table"

  company     = var.company
  environment = var.environment
  team        = var.team

  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attributes = [{
    name = "LockID"
    type = "S"
  }]
}

data "aws_iam_policy_document" "trust" {
  # https://aws.amazon.com/blogs/security/announcing-an-update-to-iam-role-trust-policy-behavior/
  statement {
    sid    = "ExplicitSelfRoleAssumption"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${local.account_id}:role/${module.prefix_and_tags.qualified_prefix}-iam-role-${var.iam_role_name}"]
    }
  }
  statement {
    sid    = "AdminRoleAssumption"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [for user in var.admin_users : "arn:aws:iam::${local.account_id}:user/${user}"]
    }
    actions = ["sts:AssumeRole"]
  }
}


module "iam_assumable_role_admin" {
  source = "git@github.com:CardoAI/infrastructure-terraform-modules.git//modules/iam/iam-assumable-role?ref=iam/iam-assumable-role/v1.0.0"

  company     = var.company
  environment = var.environment
  team        = var.team

  custom_role_trust_policy = data.aws_iam_policy_document.trust.json

  create_role             = true
  create_instance_profile = false

  role_name         = var.iam_role_name
  role_requires_mfa = false

  attach_admin_policy = true

  tags = { Role = "Terraform Admin" }
}
