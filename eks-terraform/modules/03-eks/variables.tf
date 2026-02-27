variable "project_name" {
  description = "Project name used for EKS naming and tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS control plane and node group"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "node_instance_types" {
  description = "List of EC2 instance types for the managed node group"
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired capacity of the managed node group"
  type        = number
}

variable "node_min_size" {
  description = "Minimum capacity of the managed node group"
  type        = number
}

variable "node_max_size" {
  description = "Maximum capacity of the managed node group"
  type        = number
}

variable "tags" {
  description = "Common tags to apply to EKS-related resources"
  type        = map(string)
  default     = {}
}

