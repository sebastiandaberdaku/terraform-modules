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
# IAM policy
################################################################################
variable "create_policy" {
  description = "Whether to create the IAM policy"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the policy"
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "IAM policy name prefix"
  type        = string
  default     = null
}

variable "path" {
  description = "The path of the policy in IAM"
  type        = string
  default     = "/"
}

variable "description" {
  description = "The description of the policy"
  type        = string
  default     = "IAM Policy"
}

variable "policy" {
  description = "The path of the policy in IAM (tpl file)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}