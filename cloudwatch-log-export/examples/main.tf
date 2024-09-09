module "prefix_and_tags" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//prefix-and-tags?ref=prefix-and-tags/v1.0.0"

  company     = var.company
  environment = var.environment
  team        = var.team
}

module "cloudwatch_log_export" {
  source                    = "../"
  create                    = true
  create_destination_bucket = true
  name_prefix               = module.prefix_and_tags.qualified_prefix
  tags                      = module.prefix_and_tags.tags
}