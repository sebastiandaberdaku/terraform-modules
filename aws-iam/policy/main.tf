module "prefix_and_tags" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//prefix-and-tags?ref=prefix-and-tags/v1.0.0"

  company     = var.company
  environment = var.environment
  team        = var.team
}

locals {
  has_prefix  = (var.name_prefix != null) && (var.name_prefix != "")
  name        = local.has_prefix ? null : "${module.prefix_and_tags.qualified_prefix}-iam-policy-${var.name}"
  name_prefix = local.has_prefix ? "${module.prefix_and_tags.qualified_prefix}-iam-policy-${var.name_prefix}" : null
}

module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.33.0"

  create_policy = var.create_policy
  name          = local.name
  name_prefix   = local.name_prefix
  path          = var.path
  description   = var.description
  policy        = var.policy
  tags          = merge(module.prefix_and_tags.tags, var.tags)
}