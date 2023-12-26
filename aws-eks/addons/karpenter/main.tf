module "prefix_and_tags" {
  source = "git@github.com:sebastiandaberdaku/terraform-modules.git//prefix-and-tags"

  company     = var.company
  environment = var.environment
  team        = var.team
}

locals {
  has_irsa_name    = (var.irsa_name != null) && (var.irsa_name != "")
  irsa_base_name   = local.has_irsa_name ? var.irsa_name : "karpenter"
  irsa_name        = "${module.prefix_and_tags.qualified_prefix}-irsa-eks-cl-${var.eks_cluster_base_name}-${local.irsa_base_name}"
  irsa_policy_name = "${module.prefix_and_tags.qualified_prefix}-iam-policy-eks-cl-${var.eks_cluster_base_name}-${local.irsa_base_name}"

  has_queue_name  = (var.queue_name != null) && (var.queue_name != "")
  queue_base_name = local.has_queue_name ? var.queue_name : "karpenter"
  queue_name      = "${module.prefix_and_tags.qualified_prefix}-sqs-queue-eks-cl-${var.eks_cluster_base_name}-${local.queue_base_name}"

  has_iam_role_name  = (var.iam_role_name != null) && (var.iam_role_name != "")
  iam_role_base_name = local.has_iam_role_name ? var.iam_role_name : "karpenter"
  iam_role_name      = "${module.prefix_and_tags.qualified_prefix}-iam-role-eks-cl-${var.eks_cluster_base_name}-${local.iam_role_base_name}"

  has_rule_name_prefix  = (var.rule_name_prefix != null) && (var.rule_name_prefix != "")
  base_rule_name_prefix = local.has_rule_name_prefix ? var.rule_name_prefix : "karpenter"
  rule_name_prefix      = "${module.prefix_and_tags.qualified_prefix}-eventbridge-rule-eks-cl-${var.eks_cluster_base_name}-${local.base_rule_name_prefix}"
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  create       = var.create
  tags         = merge(module.prefix_and_tags.tags, var.tags)
  cluster_name = var.cluster_name

  create_irsa                                = var.create_irsa
  irsa_name                                  = local.irsa_name
  irsa_policy_name                           = local.irsa_policy_name
  irsa_use_name_prefix                       = var.irsa_use_name_prefix
  irsa_path                                  = var.irsa_path
  irsa_description                           = var.irsa_description
  irsa_max_session_duration                  = var.irsa_max_session_duration
  irsa_permissions_boundary_arn              = var.irsa_permissions_boundary_arn
  irsa_tags                                  = var.irsa_tags
  policies                                   = var.policies
  irsa_tag_key                               = var.irsa_tag_key
  irsa_tag_values                            = var.irsa_tag_values
  irsa_ssm_parameter_arns                    = var.irsa_ssm_parameter_arns
  irsa_subnet_account_id                     = var.irsa_subnet_account_id
  irsa_oidc_provider_arn                     = var.irsa_oidc_provider_arn
  irsa_namespace_service_accounts            = ["${var.namespace}:${var.service_account}"]
  irsa_assume_role_condition_test            = var.irsa_assume_role_condition_test
  enable_karpenter_instance_profile_creation = var.enable_karpenter_instance_profile_creation

  enable_spot_termination                 = var.enable_spot_termination
  queue_name                              = local.queue_name
  queue_managed_sse_enabled               = var.queue_managed_sse_enabled
  queue_kms_master_key_id                 = var.queue_kms_master_key_id
  queue_kms_data_key_reuse_period_seconds = var.queue_kms_data_key_reuse_period_seconds

  create_iam_role               = var.create_iam_role
  cluster_ip_family             = var.cluster_ip_family
  iam_role_arn                  = var.iam_role_arn
  iam_role_name                 = local.iam_role_name
  iam_role_use_name_prefix      = var.iam_role_use_name_prefix
  iam_role_path                 = var.iam_role_path
  iam_role_description          = var.iam_role_description
  iam_role_max_session_duration = var.iam_role_max_session_duration
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  iam_role_attach_cni_policy    = var.iam_role_attach_cni_policy
  iam_role_additional_policies  = var.iam_role_additional_policies
  iam_role_tags                 = var.iam_role_tags
  create_instance_profile       = var.create_instance_profile
  rule_name_prefix              = local.rule_name_prefix
}

resource "helm_release" "karpenter" {
  count            = var.create ? 1 : 0
  namespace        = var.namespace
  create_namespace = true

  name        = "karpenter"
  repository  = "oci://public.ecr.aws/karpenter"
  chart       = "karpenter"
  version     = var.helm_chart_version
  max_history = 3
  timeout     = 900

  set {
    name  = "settings.aws.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "settings.aws.clusterEndpoint"
    value = var.cluster_endpoint
  }
  set {
    name  = "serviceAccount.name"
    value = var.service_account
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }
  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }
  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }
  set {
    name  = "replicas"
    value = var.karpenter_replicas
  }
  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key"
    value = "karpenter.sh/nodepool"
  }
  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator"
    value = "DoesNotExist"
  }
  dynamic "set" {
    for_each = length(var.destination_node_group_ids) > 0 ? [1] : []
    content {
      name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[1].matchExpressions[0].key"
      value = "eks.amazonaws.com/nodegroup"
    }
  }
  dynamic "set" {
    for_each = length(var.destination_node_group_ids) > 0 ? [1] : []
    content {
      name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[1].matchExpressions[0].operator"
      value = "In"
    }
  }
  dynamic "set" {
    for_each = { for i, v in var.destination_node_group_ids : i => v }
    content {
      name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[1].matchExpressions[0].values[${set.key}]"
      value = set.value
    }
  }

  set {
    name  = "tolerations[0].key"
    value = "CriticalAddonsOnly"
  }
  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }
  set {
    name  = "tolerations[1].key"
    value = "dedicated"
  }
  set {
    name  = "tolerations[1].operator"
    value = "Equal"
  }
  set {
    name  = "tolerations[1].value"
    value = "karpenter"
  }
  set {
    name  = "tolerations[1].effect"
    value = "NoSchedule"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "500m"
  }
  set {
    name  = "controller.resources.requests.memory"
    value = "1Gi"
  }
  set {
    name  = "controller.resources.limits.cpu"
    value = "500m"
  }
  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }
}

locals {
  karpenter_extra_chart_path = "${path.module}/karpenter-extra"
  karpenter_extra_hashes = {
    for path in sort(fileset(local.karpenter_extra_chart_path, "**")) :
    path => filebase64sha512("${local.karpenter_extra_chart_path}/${path}")
  }
  karpenter_extra_hash = base64sha512(jsonencode(local.karpenter_extra_hashes))
}

resource "helm_release" "karpenter_extra" {
  count        = var.create ? 1 : 0
  depends_on   = [helm_release.karpenter]
  name         = "karpenter-extra"
  chart        = local.karpenter_extra_chart_path
  namespace    = var.namespace
  max_history  = 3
  timeout      = 900
  reset_values = true

  set {
    name  = "templatesHash"
    value = local.karpenter_extra_hash
  }

  set {
    name  = "eksClusterName"
    value = var.cluster_name
  }

  dynamic "set" {
    for_each = { for key, value in var.karpenter_node_pools : key => value if(value.node_class_name != null) && (value.node_class_name != "") }
    content {
      name  = "nodePools.${set.key}.nodeClassName"
      value = set.value.node_class_name
    }
  }
  dynamic "set" {
    for_each = flatten([for provisioner, config in var.karpenter_node_pools : [for i, taint in config.taints : [for k, v in tomap(taint) : { i = i, node_pool = node_pool, k = k, v = v }]]])
    content {
      name  = "nodePools.${set.value.node_pool}.taints[${set.value.i}].${set.value.k}"
      value = set.value.v
      type  = "string"
    }
  }
  dynamic "set" {
    for_each = flatten([for node_pool, config in var.karpenter_node_pools : [for label, value in config.labels : { node_pool = node_pool, label = label, value = value }]])
    content {
      name  = "nodePools.${set.value.node_pool}.labels.${set.value.label}"
      value = set.value.value
      type  = "string"
    }
  }
  dynamic "set" {
    for_each = flatten([for node_pool, config in var.karpenter_node_pools : [for annotation, value in config.annotations : { node_pool = node_pool, annotation = annotation, value = value }]])
    content {
      name  = "nodePools.${set.value.node_pool}.annotations.${set.value.annotation}"
      value = set.value.value
      type  = "string"
    }
  }
  dynamic "set" {
    for_each = flatten([for node_pool, config in var.karpenter_node_pools : [for i, requirement in config.requirements : { i = i, node_pool = node_pool, key = requirement.key }]])
    content {
      name  = "nodePools.${set.value.node_pool}.requirements[${set.value.i}].key"
      value = set.value.key
      type  = "string"
    }
  }
  dynamic "set" {
    for_each = flatten([for node_pool, config in var.karpenter_node_pools : [for i, requirement in config.requirements : { i = i, node_pool = node_pool, operator = requirement.operator }]])
    content {
      name  = "nodePools.${set.value.node_pool}.requirements[${set.value.i}].operator"
      value = set.value.operator
      type  = "string"
    }
  }
  dynamic "set" {
    for_each = flatten([for node_pool, config in var.karpenter_node_pools : [for i, requirement in config.requirements : [for j, value in requirement.values : { i = i, j = j, node_pool = node_pool, value = value }]]])
    content {
      name  = "nodePools.${set.value.node_pool}.requirements[${set.value.i}].values[${set.value.j}]"
      value = set.value.value
      type  = "string"
    }
  }
  dynamic "set" {
    for_each = flatten([for node_pool, config in var.karpenter_node_pools : [for limit, value in config.resource_limits : { node_pool = node_pool, limit = limit, value = value }]])
    content {
      name  = "nodePools.${set.value.node_pool}.resourceLimits.${set.value.limit}"
      value = set.value.value
      type  = "string"
    }
  }
  dynamic "set" {
    for_each = { for key, value in var.karpenter_node_pools : key => value }
    content {
      name  = "nodePools.${set.key}.consolidationPolicy"
      value = set.value.consolidationPolicy
    }
  }
  dynamic "set" {
    for_each = { for key, value in var.karpenter_node_pools : key => value if value.ttl_seconds_until_expired != null }
    content {
      name  = "nodePools.${set.key}.consolidateAfter"
      value = set.value.consolidateAfter
    }
  }
  dynamic "set" {
    for_each = { for key, value in var.karpenter_node_pools : key => value if value.ttl_seconds_after_empty != null }
    content {
      name  = "nodePools.${set.key}.expireAfter"
      value = set.value.expireAfter
    }
  }
  dynamic "set" {
    for_each = var.karpenter_node_pools
    content {
      name  = "nodePools.${set.key}.weight"
      value = set.value.weight
    }
  }
  dynamic "set" {
    for_each = var.karpenter_node_classes
    content {
      name  = "nodeClasses.${set.key}.detailedMonitoring"
      value = set.value.detailed_monitoring
    }
  }
  dynamic "set" {
    for_each = flatten([for node_class, config in var.karpenter_node_classes : [for i, bdm in config.block_device_mappings : { node_class = node_class, i = i, bdm = bdm }]])
    content {
      name  = "nodeClasses.${set.value.node_class}.blockDeviceMappings[${set.value.i}].deviceName"
      value = set.value.bdm.device_name
    }
  }
  dynamic "set" {
    for_each = flatten([for node_class, config in var.karpenter_node_classes : [for i, bdm in config.block_device_mappings : { node_class = node_class, i = i, bdm = bdm }]])
    content {
      name  = "nodeClasses.${set.value.node_class}.blockDeviceMappings[${set.value.i}].ebs.volumeType"
      value = set.value.bdm.ebs_volume_type
    }
  }
  dynamic "set" {
    for_each = flatten([for node_class, config in var.karpenter_node_classes : [for i, bdm in config.block_device_mappings : { node_class = node_class, i = i, bdm = bdm }]])
    content {
      name  = "nodeClasses.${set.value.node_class}.blockDeviceMappings[${set.value.i}].ebs.volumeSize"
      value = set.value.bdm.ebs_volume_size
    }
  }
  dynamic "set" {
    for_each = flatten([for node_class, config in var.karpenter_node_classes : [for i, bdm in config.block_device_mappings : { node_class = node_class, i = i, bdm = bdm }]])
    content {
      name  = "nodeClasses.${set.value.node_class}.blockDeviceMappings[${set.value.i}].ebs.encrypted"
      value = true
    }
  }
  dynamic "set" {
    for_each = flatten([for node_class, config in var.karpenter_node_classes : [for i, bdm in config.block_device_mappings : { node_class = node_class, i = i, bdm = bdm }]])
    content {
      name  = "nodeClasses.${set.value.node_class}.blockDeviceMappings[${set.value.i}].ebs.deleteOnTermination"
      value = true
    }
  }
  dynamic "set" {
    for_each = { for node_class, config in var.karpenter_node_classes : node_class => config if(config.user_data != null) && (config.user_data != "") }
    content {
      name  = "nodeClasses.${set.key}.userData"
      value = set.value.user_data
      type  = "string"
    }
  }
  dynamic "set" {
    for_each = flatten([for node_class, config in var.karpenter_node_classes : [for key, value in config.tags : { node_class = node_class, key = key, value = value }]])
    content {
      name  = "nodeClasses.${set.value.node_class}.tags.${set.value.key}"
      value = set.value.value
      type  = "string"
    }
  }
}