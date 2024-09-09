variable "create" {
  type        = bool
  default     = true
  description = "Whether to create the resources."
}

variable "name_prefix" {
  type        = string
  description = "Resource name prefix."
}

variable "tags" {
  description = "A map of tags to add to all the resources in the module."
  type        = map(string)
  default     = {}
}

variable "create_destination_bucket" {
  type        = bool
  default     = false
  description = "Whether to create the destination bucket."
}

variable "destination_bucket_lifecycle_policy" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default = [{
    id      = "log"
    enabled = true
    transition = [{
      days          = 30
      storage_class = "ONEZONE_IA"
      }, {
      days          = 90
      storage_class = "GLACIER"
    }]
    noncurrent_version_transition = [{
      days          = 30
      storage_class = "ONEZONE_IA"
      }, {
      days          = 90
      storage_class = "GLACIER"
    }]
    expiration                             = { days = 730 }
    noncurrent_version_expiration          = { days = 730 }
    abort_incomplete_multipart_upload_days = 7
  }]
}

variable "destination_bucket" {
  type        = string
  default     = ""
  description = "Destination S3 Bucket name. Defaults to \"$${var.name_prefix}-s3-bucket-cloudwatch-logs\"."
}

variable "destination_bucket_prefix" {
  type        = string
  default     = "data/!{partitionKeyFromQuery:log_group}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/log_stream=!{partitionKeyFromQuery:log_stream}/"
  description = "Destination bucket prefix."
}

variable "destination_bucket_error_prefix" {
  type        = string
  default     = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"
  description = "Destination bucket error output prefix."
}