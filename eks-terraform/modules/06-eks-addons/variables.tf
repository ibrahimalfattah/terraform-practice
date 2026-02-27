variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  type        = string
}

variable "cluster_ca" {
  description = "Base64-encoded certificate authority data for the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the EKS cluster is deployed"
  type        = string
}

variable "alb_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller service account (IRSA)"
  type        = string
}

variable "external_secrets_role_arn" {
  description = "IAM role ARN for the External Secrets Operator service account (IRSA)"
  type        = string
}

variable "tags" {
  description = "Common tags to apply where supported"
  type        = map(string)
  default     = {}
}

