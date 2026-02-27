output "external_secrets_namespace" {
  description = "Namespace where External Secrets Operator is installed"
  value       = kubernetes_namespace.external_secrets.metadata[0].name
}

output "cert_manager_namespace" {
  description = "Namespace where cert-manager is installed"
  value       = kubernetes_namespace.cert_manager.metadata[0].name
}

