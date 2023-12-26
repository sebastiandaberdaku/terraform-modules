output "s3_backend_arn" {
  value = module.s3_backend.s3_bucket_arn
}

output "dynamo_lock_table_arn" {
  value = module.dynamodb_table_lock.dynamodb_table_arn
}

output "admin_iam_role_arn" {
  value = module.iam_assumable_role_admin.iam_role_arn
}
