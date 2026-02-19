variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for tagging"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR format for SSH access, e.g. 1.2.3.4/32"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "public_key_path" {
  type        = string
  description = "Path to your SSH public key, e.g. ~/.ssh/id_rsa.pub"
}
