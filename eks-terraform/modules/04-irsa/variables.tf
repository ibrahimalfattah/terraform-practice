variable "project_name" {
  description = "Project name used for tagging and naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the EKS cluster is deployed"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL from the EKS cluster"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}

