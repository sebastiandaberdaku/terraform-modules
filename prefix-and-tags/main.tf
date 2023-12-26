locals {
  qualified_prefix            = lower("${var.company}-${var.team.id}-${var.environment.id}")
  qualified_prefix_snake_case = lower("${var.company}_${var.team.id}_${var.environment.id}")

  tags = {
    Company     = var.company
    Environment = var.environment.name
    Team        = var.team.name
    CreatedBy   = "Terraform"
  }
}