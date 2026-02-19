# =============================================================================
# modules/vpc/variables.tf – VPC Module Input Variables
# =============================================================================
# These variables define the public interface that callers (e.g. app/main.tf)
# must supply when they invoke this module.  No defaults are set, so every
# variable is REQUIRED — the caller cannot omit any of them.
# =============================================================================


# -----------------------------------------------------------------------------
# project_name
# -----------------------------------------------------------------------------
# Short identifier used as a prefix in the Name tag of every VPC resource.
# Example: "op-demo" → "op-demo-vpc", "op-demo-igw", "op-demo-public-1", …
# -----------------------------------------------------------------------------
variable "project_name" { type = string }


# -----------------------------------------------------------------------------
# vpc_cidr
# -----------------------------------------------------------------------------
# The IPv4 CIDR block that defines the entire address space of the VPC.
# All subnet CIDRs must be smaller blocks that fit inside this range.
# Example: "10.10.0.0/16" provides 65,536 addresses (10.10.0.0 – 10.10.255.255).
# Standard private ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16.
# -----------------------------------------------------------------------------
variable "vpc_cidr" { type = string }


# -----------------------------------------------------------------------------
# public_subnet_cidrs
# -----------------------------------------------------------------------------
# A list of CIDR blocks — one public subnet is created per entry.
# Subnets in this list will have `map_public_ip_on_launch = true`, making
# them accessible from the internet via the Internet Gateway.
#
# Rules:
#   • Each CIDR must be a subset of var.vpc_cidr (no overlap with each other).
#   • Length determines how many public subnets are created (and thus how many
#     AZs are used — up to the number of available AZs in the region).
#
# Example: ["10.10.1.0/24", "10.10.2.0/24"]  →  2 subnets, 256 addresses each
# -----------------------------------------------------------------------------
variable "public_subnet_cidrs" {
  type = list(string)
}


# -----------------------------------------------------------------------------
# private_subnet_cidrs
# -----------------------------------------------------------------------------
# A list of CIDR blocks — one private subnet is created per entry.
# Instances in these subnets do NOT get public IPs and cannot be reached
# directly from the internet (no IGW association or public route).
#
# Use private subnets for: RDS databases, ElastiCache, internal APIs, etc.
# Add a NAT Gateway later if private instances need outbound internet access.
#
# Example: ["10.10.11.0/24", "10.10.12.0/24"]  →  2 private subnets
# -----------------------------------------------------------------------------
variable "private_subnet_cidrs" {
  type = list(string)
}
