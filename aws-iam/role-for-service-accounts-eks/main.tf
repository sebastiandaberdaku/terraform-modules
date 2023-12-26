module "prefix_and_tags" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//prefix-and-tags"

  company     = var.company
  environment = var.environment
  team        = var.team
}

locals {
  has_prefix       = (var.role_name_prefix != null) && (var.role_name_prefix != "")
  role_name        = local.has_prefix ? null : "${module.prefix_and_tags.qualified_prefix}-irsa-eks-cl-${var.eks_cluster_base_name}-${var.role_name}"
  role_name_prefix = local.has_prefix ? "${module.prefix_and_tags.qualified_prefix}-irsa-eks-cl-${var.eks_cluster_base_name}-${var.role_name_prefix}" : null

  policy_name_prefix = "${module.prefix_and_tags.qualified_prefix}-iam-policy-eks-cl-${var.eks_cluster_base_name}"
}

module "iam_role_for_service_accounts_eks" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "5.33.0"

  create_role                   = var.create_role
  role_name                     = local.role_name
  role_path                     = var.role_path
  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  role_description              = var.role_description
  role_name_prefix              = local.role_name_prefix
  policy_name_prefix            = local.policy_name_prefix
  role_policy_arns              = var.role_policy_arns
  oidc_providers                = var.oidc_providers
  tags                          = merge(module.prefix_and_tags.tags, var.tags)
  force_detach_policies         = var.force_detach_policies
  max_session_duration          = var.max_session_duration
  assume_role_condition_test    = var.assume_role_condition_test
  allow_self_assume_role        = var.allow_self_assume_role

  attach_aws_gateway_controller_policy = var.attach_aws_gateway_controller_policy

  attach_cert_manager_policy    = var.attach_cert_manager_policy
  cert_manager_hosted_zone_arns = var.cert_manager_hosted_zone_arns

  attach_cluster_autoscaler_policy = var.attach_cluster_autoscaler_policy
  cluster_autoscaler_cluster_ids   = var.cluster_autoscaler_cluster_ids
  cluster_autoscaler_cluster_names = var.cluster_autoscaler_cluster_names

  attach_ebs_csi_policy         = var.attach_ebs_csi_policy
  ebs_csi_kms_cmk_ids           = var.ebs_csi_kms_cmk_ids
  attach_efs_csi_policy         = var.attach_efs_csi_policy
  attach_external_dns_policy    = var.attach_external_dns_policy
  external_dns_hosted_zone_arns = var.external_dns_hosted_zone_arns

  attach_external_secrets_policy                     = var.attach_external_secrets_policy
  external_secrets_ssm_parameter_arns                = var.external_secrets_ssm_parameter_arns
  external_secrets_secrets_manager_arns              = var.external_secrets_secrets_manager_arns
  external_secrets_kms_key_arns                      = var.external_secrets_kms_key_arns
  external_secrets_secrets_manager_create_permission = var.external_secrets_secrets_manager_create_permission

  attach_fsx_lustre_csi_policy     = var.attach_fsx_lustre_csi_policy
  fsx_lustre_csi_service_role_arns = var.fsx_lustre_csi_service_role_arns

  attach_karpenter_controller_policy         = var.attach_karpenter_controller_policy
  karpenter_controller_cluster_id            = var.karpenter_controller_cluster_id
  karpenter_controller_cluster_name          = var.karpenter_controller_cluster_name
  karpenter_tag_key                          = var.karpenter_tag_key
  karpenter_controller_ssm_parameter_arns    = var.karpenter_controller_ssm_parameter_arns
  karpenter_controller_node_iam_role_arns    = var.karpenter_controller_node_iam_role_arns
  karpenter_subnet_account_id                = var.karpenter_subnet_account_id
  karpenter_sqs_queue_arn                    = var.karpenter_sqs_queue_arn
  enable_karpenter_instance_profile_creation = var.enable_karpenter_instance_profile_creation

  attach_load_balancer_controller_policy                          = var.attach_load_balancer_controller_policy
  attach_load_balancer_controller_targetgroup_binding_only_policy = var.attach_load_balancer_controller_targetgroup_binding_only_policy
  load_balancer_controller_targetgroup_arns                       = var.load_balancer_controller_targetgroup_arns

  attach_appmesh_controller_policy  = var.attach_appmesh_controller_policy
  attach_appmesh_envoy_proxy_policy = var.attach_appmesh_envoy_proxy_policy

  attach_amazon_managed_service_prometheus_policy  = var.attach_amazon_managed_service_prometheus_policy
  amazon_managed_service_prometheus_workspace_arns = var.amazon_managed_service_prometheus_workspace_arns

  attach_velero_policy  = var.attach_velero_policy
  velero_s3_bucket_arns = var.velero_s3_bucket_arns

  attach_vpc_cni_policy = var.attach_vpc_cni_policy
  vpc_cni_enable_ipv4   = var.vpc_cni_enable_ipv4
  vpc_cni_enable_ipv6   = var.vpc_cni_enable_ipv6

  attach_node_termination_handler_policy  = var.attach_node_termination_handler_policy
  node_termination_handler_sqs_queue_arns = var.node_termination_handler_sqs_queue_arns
  attach_cloudwatch_observability_policy  = var.attach_cloudwatch_observability_policy
}