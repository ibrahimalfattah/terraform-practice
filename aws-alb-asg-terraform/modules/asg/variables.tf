variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "instance_sg_id" { type = string }
variable "target_group_arn" { type = string }

variable "instance_type" { type = string }

variable "asg_min" { type = number }
variable "asg_desired" { type = number }
variable "asg_max" { type = number }

variable "ami_owners" { type = list(string) }
variable "ami_filter_name" { type = string }
variable "ami_filter_values" { type = list(string) }
variable "asg_health_check_type" { type = string }
variable "asg_health_check_grace_period" { type = number }
variable "lt_version" { type = string }
variable "tag_resource_type" { type = string }
variable "tag_key_name" { type = string }
variable "propagate_at_launch" { type = bool }
variable "policy_type" { type = string }
variable "predefined_metric_type" { type = string }
variable "target_value" { type = number }

variable "user_data" {
  type        = string
  description = "The user data script to run on instances upon boot."
}
