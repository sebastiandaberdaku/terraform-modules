module "prefix_and_tags" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//prefix-and-tags"

  company     = var.company
  environment = var.environment
  team        = var.team
}

locals {
  name                                   = "${module.prefix_and_tags.qualified_prefix}-iam-group-${var.name}"
  iam_self_management_policy_name_prefix = "${module.prefix_and_tags.qualified_prefix}-iam-policy-self-management-"
}

module "iam_group_with_policies" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.33.0"

  create_group                           = var.create_group
  name                                   = local.name
  path                                   = var.path
  group_users                            = var.group_users
  custom_group_policy_arns               = var.custom_group_policy_arns
  custom_group_policies                  = var.custom_group_policies
  enable_mfa_enforcement                 = var.enable_mfa_enforcement
  attach_iam_self_management_policy      = var.attach_iam_self_management_policy
  iam_self_management_policy_name_prefix = local.iam_self_management_policy_name_prefix
  aws_account_id                         = var.aws_account_id
  tags                                   = merge(module.prefix_and_tags.tags, var.tags)
}