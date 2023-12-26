output "qualified_prefix" {
  value       = local.qualified_prefix
  description = "Kebab-case prefix composed of the Company name, team and environment ids."
}

output "qualified_prefix_snake_case" {
  value       = local.qualified_prefix_snake_case
  description = "Snake-case prefix composed of the Company name, team and environment ids."
}

output "tags" {
  value       = local.tags
  description = "Omen est nomen."
}