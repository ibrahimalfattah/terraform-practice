variable "project_name" {
  description = "Project name used for tagging and naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "node_security_group_id" {
  description = "Security group ID of the EKS worker nodes allowed to access the database"
  type        = string
}

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
}

variable "db_username" {
  description = "Master username for PostgreSQL"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class for PostgreSQL"
  type        = string
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.5"
}

variable "tags" {
  description = "Common tags to apply to RDS-related resources"
  type        = map(string)
  default     = {}
}

