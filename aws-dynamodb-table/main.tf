module "prefix_and_tags" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//prefix-and-tags"

  company     = var.company
  environment = var.environment
  team        = var.team
}

locals {
  name = "${module.prefix_and_tags.qualified_prefix}-dynamodb-table-${var.name}"
}


module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.0"

  create_table = var.create_table
  name         = local.name

  attributes                     = var.attributes
  hash_key                       = var.hash_key
  range_key                      = var.range_key
  billing_mode                   = var.billing_mode
  write_capacity                 = var.write_capacity
  read_capacity                  = var.read_capacity
  point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
  ttl_enabled                    = var.ttl_enabled
  ttl_attribute_name             = var.ttl_attribute_name

  global_secondary_indexes = var.global_secondary_indexes
  local_secondary_indexes  = var.local_secondary_indexes
  replica_regions          = var.replica_regions

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type

  server_side_encryption_enabled     = var.server_side_encryption_enabled
  server_side_encryption_kms_key_arn = var.server_side_encryption_kms_key_arn

  tags     = merge(module.prefix_and_tags.tags, var.tags)
  timeouts = var.timeouts

  autoscaling_enabled  = var.autoscaling_enabled
  autoscaling_defaults = var.autoscaling_defaults
  autoscaling_read     = var.autoscaling_read
  autoscaling_write    = var.autoscaling_write
  autoscaling_indexes  = var.autoscaling_indexes

  table_class                           = var.table_class
  deletion_protection_enabled           = var.deletion_protection_enabled
  import_table                          = var.import_table
  ignore_changes_global_secondary_index = var.ignore_changes_global_secondary_index
}