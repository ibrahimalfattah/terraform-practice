variable "project_name" { type = string }
variable "subnet_id" { type = string }
variable "security_group_ids" { type = list(string) }

variable "instance_type" { type = string }

variable "public_key_path" {
  type        = string
  description = "Path to SSH public key"
}
