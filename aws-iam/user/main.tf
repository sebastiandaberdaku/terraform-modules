module "prefix_and_tags" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//prefix-and-tags?ref=prefix-and-tags/v1.0.0"

  company     = var.company
  environment = var.environment
  team        = var.team
}

locals {
  name = "${module.prefix_and_tags.qualified_prefix}-iam-user-${var.name}"
}

module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.33.0"

  create_user                   = var.create_user
  create_iam_user_login_profile = var.create_iam_user_login_profile
  create_iam_access_key         = var.create_iam_access_key
  name                          = local.name
  path                          = var.path
  force_destroy                 = var.force_destroy
  pgp_key                       = var.pgp_key
  iam_access_key_status         = var.iam_access_key_status
  password_reset_required       = var.password_reset_required
  password_length               = var.password_length
  upload_iam_user_ssh_key       = var.upload_iam_user_ssh_key
  ssh_key_encoding              = var.ssh_key_encoding
  ssh_public_key                = var.ssh_public_key
  permissions_boundary          = var.permissions_boundary
  policy_arns                   = var.policy_arns
  tags                          = merge(module.prefix_and_tags.tags, var.tags)
}