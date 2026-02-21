variable "project_name" { type = string }
variable "vpc_cidr" { type = string }

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "enable_dns_support" { type = bool }
variable "enable_dns_hostnames" { type = bool }
variable "map_public_ip_on_launch" { type = bool }
variable "public_route_destination" { type = string }
variable "eip_domain" { type = string }
variable "private_route_destination" { type = string }
