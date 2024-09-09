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