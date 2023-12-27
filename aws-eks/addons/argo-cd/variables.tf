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
# Argo CD
################################################################################

variable "create" {
  description = "Determines whether to create the resources or not."
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Name of the Kubernetes namespace to create the resource into."
  type        = string
  default     = "argo-cd"
}


variable "helm_chart_version" {
  description = "The Helm Chart version to install."
  type        = string
  default     = null
}

variable "repositories" {
  description = "ArgoCD-managed application repositories."

  type = map(object({
    type                 = string
    project              = string
    url                  = string
    ssh_private_key_path = string
  }))
}
