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
