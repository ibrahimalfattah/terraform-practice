variable "project_name" {
  description = "Project name used for ECR repository naming"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to ECR repositories"
  type        = map(string)
  default     = {}
}

