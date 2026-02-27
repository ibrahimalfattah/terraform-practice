variable "project_name" {
  description = "Project name used for namespace and resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region where Secrets Manager is hosted"
  type        = string
}

variable "frontend_repo_url" {
  description = "ECR repository URL for the frontend image"
  type        = string
}

variable "backend_repo_url" {
  description = "ECR repository URL for the backend image"
  type        = string
}

variable "frontend_image_tag" {
  description = "Docker image tag for the frontend container"
  type        = string
}

variable "backend_image_tag" {
  description = "Docker image tag for the backend container"
  type        = string
}

variable "frontend_container_port" {
  description = "Container port exposed by the frontend application"
  type        = number
}

variable "backend_container_port" {
  description = "Container port exposed by the backend application"
  type        = number
}

variable "backend_health_path" {
  description = "HTTP path used for backend health checks"
  type        = string
}

variable "db_endpoint" {
  description = "Endpoint of the PostgreSQL database"
  type        = string
}

variable "db_port" {
  description = "Port of the PostgreSQL database"
  type        = number
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_secret_name" {
  description = "Name of the Secrets Manager secret containing the DB password"
  type        = string
}

variable "app_domain" {
  description = "Public DNS name for the application"
  type        = string
}

variable "enable_tls" {
  description = "Whether to enable TLS via cert-manager and Let's Encrypt"
  type        = bool
}

variable "acme_email" {
  description = "Email address used for Let's Encrypt ACME registration"
  type        = string
}

