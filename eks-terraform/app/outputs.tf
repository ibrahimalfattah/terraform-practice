// Root outputs re-exporting key values from submodules

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "frontend_repo_url" {
  description = "ECR repository URL for the frontend image"
  value       = module.ecr.frontend_repo_url
}

output "backend_repo_url" {
  description = "ECR repository URL for the backend image"
  value       = module.ecr.backend_repo_url
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca" {
  description = "Certificate authority data for the EKS cluster"
  value       = module.eks.cluster_ca
}

output "eks_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster"
  value       = module.eks.oidc_issuer_url
}

output "db_endpoint" {
  description = "Endpoint address of the RDS PostgreSQL instance"
  value       = module.rds_postgres.db_endpoint
}

output "db_port" {
  description = "Port of the RDS PostgreSQL instance"
  value       = module.rds_postgres.db_port
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret storing the DB password"
  value       = module.rds_postgres.db_secret_arn
}

output "db_secret_name" {
  description = "Name of the Secrets Manager secret storing the DB password"
  value       = module.rds_postgres.db_secret_name
}

output "db_username" {
  description = "Database master username"
  value       = module.rds_postgres.db_username
}

output "db_name" {
  description = "Database name"
  value       = module.rds_postgres.db_name
}

output "ingress_namespace" {
  description = "Namespace of the application ingress"
  value       = module.k8s_apps.ingress_namespace
}

output "ingress_name" {
  description = "Name of the application ingress resource"
  value       = module.k8s_apps.ingress_name
}

output "alb_dns_hostname" {
  description = "DNS hostname of the ALB created by the ingress"
  value       = module.k8s_apps.alb_dns_hostname
}

output "dns_instructions" {
  description = "Instructions for creating the DNS record pointing to the ALB"
  value       = module.k8s_apps.dns_instructions
}

