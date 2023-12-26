variable "company" {
  description = "The name of your company"
  type        = string
}

variable "environment" {
  description = "Environment"
  type = object({
    name = string
    id   = string
  })
}

variable "team" {
  description = "The Team who is going to use the resource."
  type = object({
    name = string
    id   = string
  })
}

################################################################################
# Karpenter
################################################################################
variable "create" {
  description = "Determines whether to create EKS managed node group or not"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = ""
}

################################################################################
# IAM Role for Service Account (IRSA)
################################################################################

variable "create_irsa" {
  description = "Determines whether an IAM role for service accounts is created"
  type        = bool
  default     = true
}

variable "irsa_name" {
  description = "Name of IAM role for service accounts"
  type        = string
  default     = null
}

variable "eks_cluster_base_name" {
  description = "The base name of the EKS cluster"
  type        = string
}

variable "irsa_policy_name" {
  description = "Name of IAM policy for service accounts"
  type        = string
  default     = null
}

variable "irsa_use_name_prefix" {
  description = "Determines whether the IAM role for service accounts name (`irsa_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "irsa_path" {
  description = "Path of IAM role for service accounts"
  type        = string
  default     = "/"
}

variable "irsa_description" {
  description = "IAM role for service accounts description"
  type        = string
  default     = "Karpenter IAM role for service account"
}

variable "irsa_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "irsa_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role for service accounts"
  type        = string
  default     = null
}

variable "irsa_tags" {
  description = "A map of additional tags to add the the IAM role for service accounts"
  type        = map(any)
  default     = {}
}

variable "policies" {
  description = "Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
}

variable "irsa_tag_key" {
  description = "Tag key (`{key = value}`) applied to resources launched by Karpenter through the Karpenter provisioner"
  type        = string
  default     = "karpenter.sh/discovery"
}

variable "irsa_tag_values" {
  description = "Tag values (`{key = value}`) applied to resources launched by Karpenter through the Karpenter provisioner. Defaults to cluster name when not set."
  type        = list(string)
  default     = []
}

variable "irsa_ssm_parameter_arns" {
  description = "List of SSM Parameter ARNs that contain AMI IDs launched by Karpenter"
  type        = list(string)
  # https://github.com/aws/karpenter/blob/ed9473a9863ca949b61b9846c8b9f33f35b86dbd/pkg/cloudprovider/aws/ami.go#L105-L123
  default = ["arn:aws:ssm:*:*:parameter/aws/service/*"]
}

variable "irsa_subnet_account_id" {
  description = "Account ID of where the subnets Karpenter will utilize resides. Used when subnets are shared from another account"
  type        = string
  default     = ""
}

variable "irsa_oidc_provider_arn" {
  description = "OIDC provider arn used in trust policy for IAM role for service accounts"
  type        = string
  default     = ""
}

variable "irsa_assume_role_condition_test" {
  description = "Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role"
  type        = string
  default     = "StringEquals"
}

variable "enable_karpenter_instance_profile_creation" {
  description = "Determines whether Karpenter will be allowed to create the IAM instance profile (v1beta1) or if Terraform will (v1alpha1)"
  type        = bool
  default     = false
}

################################################################################
# Node Termination Queue
################################################################################

variable "enable_spot_termination" {
  description = "Determines whether to enable native spot termination handling"
  type        = bool
  default     = true
}

variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = null
}

variable "queue_managed_sse_enabled" {
  description = "Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys"
  type        = bool
  default     = true
}

variable "queue_kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK"
  type        = string
  default     = null
}

variable "queue_kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again"
  type        = number
  default     = null
}

################################################################################
# Node IAM Role & Instance Profile
################################################################################

variable "create_iam_role" {
  description = "Determines whether an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`"
  type        = string
  default     = null
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the IAM instance profile. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = "/"
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_max_session_duration" {
  description = "Maximum API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_attach_cni_policy" {
  description = "Whether to attach the `AmazonEKS_CNI_Policy`/`AmazonEKS_CNI_IPv6_Policy` IAM policy to the IAM IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster"
  type        = bool
  default     = true
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Node IAM Instance Profile
################################################################################

variable "create_instance_profile" {
  description = "Whether to create an IAM instance profile"
  type        = bool
  default     = true
}

################################################################################
# Event Bridge Rules
################################################################################

variable "rule_name_prefix" {
  description = "Prefix used for all event bridge rules"
  type        = string
  default     = "Karpenter"
}


################################################################################
# HELM Release
################################################################################
variable "helm_chart_version" {
  description = "The Helm Chart version to install"
  type        = string
  default     = null
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "namespace" {
  description = "Karpenter namespace"
  type        = string
  default     = "karpenter"
}

variable "service_account" {
  description = "Karpenter service account"
  type        = string
  default     = "karpenter"
}

variable "destination_node_group_ids" {
  description = "Existing node group ids where to deploy Karpenter"
  type        = list(string)
  default     = []
}

variable "karpenter_replicas" {
  description = "Number of Karpenter replicas for High Availability"
  type        = number
  default     = 3
}

variable "karpenter_node_pools" {
  description = "Karpenter NodePools describing the desired node characteristics"
  type = map(object({
    node_class_name = optional(string, "default")
    taints = optional(list(object({
      key      = string
      operator = optional(string, "Equal")
      value    = optional(string)
      effect   = optional(string, "NoSchedule")
    })), [])
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
    requirements = list(object({
      key      = string
      operator = string
      values   = list(string)
    }))
    # Resource limits constrain the total size of the NodePool.
    # Limits prevent Karpenter from creating new instances once the limit is exceeded.
    resource_limits = map(string)
    # Describes which types of Nodes Karpenter should consider for consolidation.
    # If using 'WhenUnderutilized', Karpenter will consider all nodes for consolidation and attempt to remove or replace Nodes when it discovers that the Node is underutilized and could be changed to reduce cost.
    # If using `WhenEmpty`, Karpenter will only consider nodes for consolidation that contain no workload pods.
    consolidationPolicy : optional(string, "WhenUnderutilized")
    # The amount of time Karpenter should wait after discovering a consolidation decision.
    # This value can currently only be set when the consolidationPolicy is 'WhenEmpty'.
    # You can choose to disable consolidation entirely by setting the string value 'Never' here.
    consolidateAfter = optional(string, "30s")
    # The amount of time a Node can live on the cluster before being removed.
    # Avoiding long-running Nodes helps to reduce security vulnerabilities as well as to reduce the chance of issues that can plague Nodes with long uptimes such as file fragmentation or memory leaks from system processes.
    # You can choose to disable expiration entirely by setting the string value 'Never' here.
    expireAfter = optional(string, "720h")
    # Priority given to the NodePool when the scheduler considers which NodePool
    # to select. Higher weights indicate higher priority when comparing NodePools.
    # Specifying no weight is equivalent to specifying a weight of 0.
    weight = optional(number, 10)
  }))
  validation {
    condition     = length(keys(var.karpenter_node_pools)) > 0
    error_message = "At least one provisioner configuration must be provided!"
  }
  validation {
    condition     = alltrue(flatten([for key, value in var.karpenter_node_pools : [for taint in value.taints : contains(["NoSchedule", "PreferNoSchedule", "NoExecute"], taint.effect)]]))
    error_message = "Allowed values for taint effects are: \"NoSchedule\", \"PreferNoSchedule\", and \"NoExecute\"!"
  }
  validation {
    condition     = alltrue(flatten([for key, value in var.karpenter_node_pools : [for taint in value.taints : contains(["Exists", "Equal"], taint.operator)]]))
    error_message = "Allowed values for taint operators are: \"Exists\", and \"Equal\"!"
  }
  validation {
    condition     = alltrue([for key, value in var.karpenter_node_pools : length(keys(value.resource_limits)) > 0])
    error_message = "A non-empty \"resource_limits\" map must be provided for each provisioner!"
  }
}

variable "karpenter_node_classes" {
  description = "Karpenter NodeClasses describing the desired node characteristics"
  type = map(object({
    # Controls the EC2 detailed monitoring feature. If you enable this option, the Amazon EC2 console displays
    # monitoring graphs with a 1-minute period for the instances that Karpenter launches.
    detailed_monitoring = optional(bool, false)
    block_device_mappings = list(object({
      device_name     = string
      ebs_volume_type = string
      ebs_volume_size = string
    }))
    user_data = optional(string)
    tags      = optional(map(string))
  }))
}