output "aws_account_id" {
  description = "IAM AWS account id"
  value       = module.iam_group_with_policies.aws_account_id
}

output "group_arn" {
  description = "IAM group arn"
  value       = module.iam_group_with_policies.group_arn
}

output "group_users" {
  description = "List of IAM users in IAM group"
  value       = module.iam_group_with_policies.group_users
}

output "group_name" {
  description = "IAM group name"
  value       = module.iam_group_with_policies.group_name
}
