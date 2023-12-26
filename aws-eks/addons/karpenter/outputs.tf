################################################################################
# IAM Role for Service Account (IRSA)
################################################################################

output "irsa_name" {
  description = "The name of the IAM role for service accounts"
  value       = module.karpenter.irsa_name
}

output "irsa_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role for service accounts"
  value       = module.karpenter.irsa_arn
}

output "irsa_unique_id" {
  description = "Stable and unique string identifying the IAM role for service accounts"
  value       = module.karpenter.irsa_unique_id
}

################################################################################
# Node Termination Queue
################################################################################

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.karpenter.queue_arn
}

output "queue_name" {
  description = "The name of the created Amazon SQS queue"
  value       = module.karpenter.queue_name
}

output "queue_url" {
  description = "The URL for the created Amazon SQS queue"
  value       = module.karpenter.queue_url
}

################################################################################
# Node Termination Event Rules
################################################################################

output "event_rules" {
  description = "Map of the event rules created and their attributes"
  value       = module.karpenter.event_rules
}

################################################################################
# Node IAM Role
################################################################################

output "role_name" {
  description = "The name of the IAM role"
  value       = module.karpenter.role_name
}

output "role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.karpenter.role_arn
}

output "role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.karpenter.role_unique_id
}

################################################################################
# Node IAM Instance Profile
################################################################################

output "instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = module.karpenter.instance_profile_arn
}

output "instance_profile_id" {
  description = "Instance profile's ID"
  value       = module.karpenter.instance_profile_id
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = module.karpenter.instance_profile_name
}

output "instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = module.karpenter.instance_profile_unique
}
