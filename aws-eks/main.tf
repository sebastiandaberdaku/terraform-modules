module "prefix_and_tags" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//prefix-and-tags"

  company     = var.company
  environment = var.environment
  team        = var.team
}

locals {
  cluster_name = "${module.prefix_and_tags.qualified_prefix}-eks-${var.cluster_name}"

  iam_role_base_name = (var.iam_role_name == null) || (var.iam_role_name == "") ? "default-eks-${var.cluster_name}" : var.iam_role_name
  iam_role_name      = "${module.prefix_and_tags.qualified_prefix}-iam-role-${local.iam_role_base_name}"

  cluster_encryption_policy_base_name = (var.cluster_encryption_policy_name == null) || (var.cluster_encryption_policy_name == "") ? "encryption-eks-${var.cluster_name}" : var.cluster_encryption_policy_name
  cluster_encryption_policy_name      = "${module.prefix_and_tags.qualified_prefix}-iam-policy-${local.cluster_encryption_policy_base_name}"

  cluster_security_group_base_name = (var.cluster_security_group_name == null) || (var.cluster_security_group_name == "") ? "default-eks-${var.cluster_name}" : var.cluster_security_group_name
  cluster_security_group_name      = "${module.prefix_and_tags.qualified_prefix}-sg-${local.cluster_security_group_base_name}"

  node_security_group_base_name = (var.node_security_group_name == null) || (var.node_security_group_name == "") ? "node-default-eks-${var.cluster_name}" : var.node_security_group_name
  node_security_group_name      = "${module.prefix_and_tags.qualified_prefix}-sg-${local.node_security_group_base_name}"

  kms_key_alias       = "${module.prefix_and_tags.qualified_prefix}-kms-cmk-eks-${var.cluster_name}"
  kms_key_description = (var.node_security_group_name == null) || (var.node_security_group_name == "") ? "${local.cluster_name} EKS cluster encryption key" : var.kms_key_description
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  create           = var.create
  tags             = merge(module.prefix_and_tags.tags, var.tags)
  prefix_separator = var.prefix_separator

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  cluster_enabled_log_types             = var.cluster_enabled_log_types
  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids
  control_plane_subnet_ids              = var.control_plane_subnet_ids
  subnet_ids                            = var.subnet_ids

  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cluster_ip_family                    = var.cluster_ip_family
  cluster_service_ipv4_cidr            = var.cluster_service_ipv4_cidr


  cluster_service_ipv6_cidr                  = var.cluster_service_ipv6_cidr
  outpost_config                             = var.outpost_config
  cluster_encryption_config                  = var.cluster_encryption_config
  attach_cluster_encryption_policy           = var.attach_cluster_encryption_policy
  cluster_tags                               = var.cluster_tags
  create_cluster_primary_security_group_tags = var.create_cluster_primary_security_group_tags
  cluster_timeouts                           = var.cluster_timeouts

  create_kms_key                    = var.create_kms_key
  kms_key_description               = var.kms_key_description
  kms_key_deletion_window_in_days   = var.kms_key_deletion_window_in_days
  enable_kms_key_rotation           = var.enable_kms_key_rotation
  kms_key_enable_default_policy     = var.kms_key_enable_default_policy
  kms_key_owners                    = var.kms_key_owners
  kms_key_administrators            = var.kms_key_administrators
  kms_key_users                     = var.kms_key_users
  kms_key_service_users             = var.kms_key_service_users
  kms_key_source_policy_documents   = var.kms_key_source_policy_documents
  kms_key_override_policy_documents = var.kms_key_override_policy_documents
  kms_key_aliases                   = concat([local.kms_key_alias], var.kms_key_aliases)

  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_tags              = var.cloudwatch_log_group_tags

  create_cluster_security_group           = var.create_cluster_security_group
  cluster_security_group_id               = var.cluster_security_group_id
  vpc_id                                  = var.vpc_id
  cluster_security_group_name             = local.cluster_security_group_name
  cluster_security_group_use_name_prefix  = var.cluster_security_group_use_name_prefix
  cluster_security_group_description      = var.cluster_security_group_description
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  cluster_security_group_tags             = var.cluster_security_group_tags
  create_cni_ipv6_iam_policy              = var.create_cni_ipv6_iam_policy

  create_node_security_group                   = var.create_node_security_group
  node_security_group_id                       = var.node_security_group_id
  node_security_group_name                     = local.node_security_group_name
  node_security_group_use_name_prefix          = var.node_security_group_use_name_prefix
  node_security_group_description              = var.node_security_group_description
  node_security_group_additional_rules         = var.node_security_group_additional_rules
  node_security_group_enable_recommended_rules = var.node_security_group_enable_recommended_rules
  node_security_group_tags                     = var.node_security_group_tags

  enable_irsa                     = var.enable_irsa
  openid_connect_audiences        = var.openid_connect_audiences
  include_oidc_root_ca_thumbprint = var.include_oidc_root_ca_thumbprint
  custom_oidc_thumbprints         = var.custom_oidc_thumbprints
  create_iam_role                 = var.create_iam_role
  iam_role_arn                    = var.iam_role_arn
  iam_role_name                   = local.iam_role_name
  iam_role_use_name_prefix        = var.iam_role_use_name_prefix
  iam_role_path                   = var.iam_role_path
  iam_role_description            = var.iam_role_description
  iam_role_permissions_boundary   = var.iam_role_permissions_boundary
  iam_role_additional_policies    = var.iam_role_additional_policies
  cluster_iam_role_dns_suffix     = var.cluster_iam_role_dns_suffix
  iam_role_tags                   = var.iam_role_tags

  cluster_encryption_policy_use_name_prefix        = var.cluster_encryption_policy_use_name_prefix
  cluster_encryption_policy_name                   = local.cluster_encryption_policy_name
  cluster_encryption_policy_description            = var.cluster_encryption_policy_description
  cluster_encryption_policy_path                   = var.cluster_encryption_policy_path
  cluster_encryption_policy_tags                   = var.cluster_encryption_policy_tags
  dataplane_wait_duration                          = var.dataplane_wait_duration
  cluster_addons                                   = var.cluster_addons
  cluster_addons_timeouts                          = var.cluster_addons_timeouts
  cluster_identity_providers                       = var.cluster_identity_providers
  fargate_profiles                                 = var.fargate_profiles
  fargate_profile_defaults                         = var.fargate_profile_defaults
  self_managed_node_groups                         = var.self_managed_node_groups
  self_managed_node_group_defaults                 = var.self_managed_node_group_defaults
  eks_managed_node_groups                          = var.eks_managed_node_groups
  eks_managed_node_group_defaults                  = var.eks_managed_node_group_defaults
  manage_aws_auth_configmap                        = var.manage_aws_auth_configmap
  create_aws_auth_configmap                        = var.create_aws_auth_configmap
  aws_auth_node_iam_role_arns_non_windows          = var.aws_auth_node_iam_role_arns_non_windows
  aws_auth_node_iam_role_arns_windows              = var.aws_auth_node_iam_role_arns_windows
  aws_auth_fargate_profile_pod_execution_role_arns = var.aws_auth_fargate_profile_pod_execution_role_arns
  aws_auth_roles                                   = var.aws_auth_roles
  aws_auth_users                                   = var.aws_auth_users
  aws_auth_accounts                                = var.aws_auth_accounts
}