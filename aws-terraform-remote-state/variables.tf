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

variable "admin_users" {
  description = "List of AWS user names that can assume the Terraform Admin role."
  type        = list(string)
  validation {
    condition     = length(var.admin_users) > 0
    error_message = "At least one admin user must be provided!"
  }
  validation {
    condition     = alltrue([for u in var.admin_users : (u != null) && (u != "")])
    error_message = "Admin user names cannot be null or empty!"
  }
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to create."
  type        = string
  default     = "terraform-remote-state"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB Table to create."
  type        = string
  default     = "terraform-lock"
}

variable "iam_role_name" {
  description = "Name of the Admin IAM role to create."
  type        = string
  default     = "terraform-admin"
}