variable "company" {
  description = "The name of your company"
  type        = string
  validation {
    condition     = (var.company != null) && (var.company != "")
    error_message = "The company cannot be null or empty."
  }
}

variable "environment" {
  description = "Environment"
  type = object({
    name = string
    id   = string
  })
  validation {
    condition     = contains(["development", "staging", "production"], var.environment.name)
    error_message = "Allowed values for environment.name are: [\"development\", \"staging\", \"production\"]."
  }
  validation {
    condition     = contains(["dv", "st", "pr"], var.environment.id)
    error_message = "Allowed values for environment.id are [\"dv\", \"st\", \"pr\"]."
  }
}

variable "team" {
  description = "The Team who is going to use the resource."
  type = object({
    name = string
    id   = string
  })
  validation {
    condition     = (var.team.name != null) && (var.team.name != "")
    error_message = "The team.name cannot be null or empty."
  }
  validation {
    condition     = length(var.team.id) == 2
    error_message = "The team.id must be 2 characters long."
  }
}

################################################################################
# IAM group with policies
################################################################################
variable "create_group" {
  description = "Whether to create IAM group"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of IAM group"
  type        = string
  default     = ""
}

variable "path" {
  description = "Desired path for the IAM group"
  type        = string
  default     = "/"
}

variable "group_users" {
  description = "List of IAM users to have in an IAM group which can assume the role"
  type        = list(string)
  default     = []
}

variable "custom_group_policy_arns" {
  description = "List of IAM policies ARNs to attach to IAM group"
  type        = list(string)
  default     = []
}

variable "custom_group_policies" {
  description = "List of maps of inline IAM policies to attach to IAM group. Should have `name` and `policy` keys in each element."
  type        = list(map(string))
  default     = []
}

variable "enable_mfa_enforcement" {
  description = "Determines whether permissions are added to the policy which requires the groups IAM users to use MFA"
  type        = bool
  default     = true
}

variable "attach_iam_self_management_policy" {
  description = "Whether to attach IAM policy which allows IAM users to manage their credentials and MFA"
  type        = bool
  default     = true
}

variable "aws_account_id" {
  description = "AWS account id to use inside IAM policies. If empty, current AWS account ID will be used."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}