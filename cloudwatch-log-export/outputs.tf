output "firehose_service_role_arn" {
  value       = module.firehose_to_s3_role.iam_role_arn
  description = "Kinesis Firehose Data Stream service role ARN."
}

output "firehose_service_role_name" {
  value       = module.firehose_to_s3_role.iam_role_name
  description = "Kinesis Firehose Data Stream service role name."
}

output "cloudwatch_service_role_arn" {
  value       = module.cloudwatch_to_firehose_role.iam_role_arn
  description = "CloudWatch account subscription filter IAM Role ARN."
}

output "cloudwatch_service_role_name" {
  value       = module.cloudwatch_to_firehose_role.iam_role_name
  description = "CloudWatch account subscription filter IAM Role name."
}

output "kinesis_firehose_delivery_stream_arn" {
  value       = try(aws_kinesis_firehose_delivery_stream.cloudwatch_log_exporter[0].arn, "")
  description = "Created Kinesis Firehose Delivery Stream ARN."
}

output "kinesis_firehose_delivery_stream_name" {
  value       = try(aws_kinesis_firehose_delivery_stream.cloudwatch_log_exporter[0].name, "")
  description = "Created Kinesis Firehose Delivery Stream name."
}

output "destination_bucket" {
  value       = local.destination_bucket
  description = "Destination S3 Bucket name."
}

output "destination_bucket_arn" {
  value       = local.destination_bucket_arn
  description = "Destination S3 Bucket ARN."
}

output "cloudwatch_log_account_policy_name" {
  value       = try(aws_cloudwatch_log_account_policy.cloudwatch_log_exporter[0].policy_name, "")
  description = "CloudWatch account subscription filter name."
}