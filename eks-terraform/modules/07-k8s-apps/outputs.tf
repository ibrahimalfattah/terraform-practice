output "ingress_namespace" {
  description = "Namespace of the application ingress"
  value       = kubernetes_ingress_v1.app.metadata[0].namespace
}

output "ingress_name" {
  description = "Name of the application ingress"
  value       = kubernetes_ingress_v1.app.metadata[0].name
}

output "alb_dns_hostname" {
  description = "DNS hostname of the ALB created for the ingress"
  value       = try(kubernetes_ingress_v1.app.status[0].load_balancer[0].ingress[0].hostname, "")
}

output "dns_instructions" {
  description = "Instructions for creating the CNAME record pointing to the ALB"
  value       = "Create a CNAME record in your DNS provider: ${var.app_domain} -> ${try(kubernetes_ingress_v1.app.status[0].load_balancer[0].ingress[0].hostname, "<ALB_HOSTNAME>")}"
}

