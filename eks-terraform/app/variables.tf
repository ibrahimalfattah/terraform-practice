// Root module variables

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging and resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (first 2 AZs)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (first 2 AZs)"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "List of EC2 instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired size of the EKS managed node group"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum size of the EKS managed node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum size of the EKS managed node group"
  type        = number
  default     = 4
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class for PostgreSQL"
  type        = string
  default     = "db.t3.micro"
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

variable "frontend_image_tag" {
  description = "Docker image tag for the frontend container"
  type        = string
}

variable "backend_image_tag" {
  description = "Docker image tag for the backend container"
  type        = string
}

variable "enable_tls" {
  description = "Whether to enable TLS via cert-manager and Let's Encrypt"
  type        = bool
  default     = false
}

variable "app_domain" {
  description = "Public DNS name for the application (FQDN)"
  type        = string
}

variable "acme_email" {
  description = "Email address used for Let's Encrypt ACME registration"
  type        = string
}

