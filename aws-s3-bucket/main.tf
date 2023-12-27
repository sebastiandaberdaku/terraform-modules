module "prefix_and_tags" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//prefix-and-tags?ref=prefix-and-tags/v1.0.0"

  company     = var.company
  environment = var.environment
  team        = var.team
}

locals {
  policies     = var.policies == null ? [] : compact(var.policies)
  has_policies = length(local.policies) > 0
}

data "aws_iam_policy_document" "bucket_policy" {
  count                   = local.has_policies ? 1 : 0
  source_policy_documents = local.policies
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  create_bucket                              = var.create_bucket
  attach_elb_log_delivery_policy             = var.attach_elb_log_delivery_policy
  attach_lb_log_delivery_policy              = var.attach_lb_log_delivery_policy
  attach_access_log_delivery_policy          = var.attach_access_log_delivery_policy
  attach_deny_insecure_transport_policy      = var.attach_deny_insecure_transport_policy
  attach_require_latest_tls_policy           = var.attach_require_latest_tls_policy
  attach_policy                              = var.attach_policy
  attach_public_policy                       = var.attach_public_policy
  attach_inventory_destination_policy        = var.attach_inventory_destination_policy
  attach_analytics_destination_policy        = var.attach_analytics_destination_policy
  attach_deny_incorrect_encryption_headers   = var.attach_deny_incorrect_encryption_headers
  attach_deny_incorrect_kms_key_sse          = var.attach_deny_incorrect_kms_key_sse
  allowed_kms_key_arn                        = var.allowed_kms_key_arn
  attach_deny_unencrypted_object_uploads     = var.attach_deny_unencrypted_object_uploads
  bucket                                     = var.bucket == null ? null : "${module.prefix_and_tags.qualified_prefix}-s3-bucket-${var.bucket}"
  bucket_prefix                              = var.bucket_prefix == null ? null : "${module.prefix_and_tags.qualified_prefix}-s3-bucket-${var.bucket_prefix}"
  acl                                        = var.acl
  policy                                     = local.has_policies ? data.aws_iam_policy_document.bucket_policy[0].json : null
  tags                                       = merge(module.prefix_and_tags.tags, var.tags)
  force_destroy                              = var.force_destroy
  acceleration_status                        = var.acceleration_status
  request_payer                              = var.request_payer
  website                                    = var.website
  cors_rule                                  = var.cors_rule
  versioning                                 = var.versioning
  logging                                    = var.logging
  access_log_delivery_policy_source_buckets  = var.access_log_delivery_policy_source_buckets
  access_log_delivery_policy_source_accounts = var.access_log_delivery_policy_source_accounts
  grant                                      = var.grant
  owner                                      = var.owner
  expected_bucket_owner                      = var.expected_bucket_owner
  lifecycle_rule                             = var.lifecycle_rule
  replication_configuration                  = var.replication_configuration
  server_side_encryption_configuration       = var.server_side_encryption_configuration
  intelligent_tiering                        = var.intelligent_tiering
  object_lock_configuration                  = var.object_lock_configuration
  metric_configuration                       = var.metric_configuration
  inventory_configuration                    = var.inventory_configuration
  inventory_source_account_id                = var.inventory_source_account_id
  inventory_source_bucket_arn                = var.inventory_source_bucket_arn
  inventory_self_source_destination          = var.inventory_self_source_destination
  analytics_configuration                    = var.analytics_configuration
  analytics_source_account_id                = var.analytics_source_account_id
  analytics_source_bucket_arn                = var.analytics_source_bucket_arn
  analytics_self_source_destination          = var.analytics_self_source_destination
  object_lock_enabled                        = var.object_lock_enabled
  block_public_acls                          = var.block_public_acls
  block_public_policy                        = var.block_public_policy
  ignore_public_acls                         = var.ignore_public_acls
  restrict_public_buckets                    = var.restrict_public_buckets
  control_object_ownership                   = var.control_object_ownership
  object_ownership                           = var.object_ownership
}