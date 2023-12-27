output "admin_password" {
  description = "ArgoCD Administrator password"
  value       = try(data.kubernetes_secret_v1.admin_secret[0].data["password"], "")
  sensitive   = true
}

output "namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = var.namespace
}
