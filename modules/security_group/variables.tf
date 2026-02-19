# =============================================================================
# modules/security_group/variables.tf – Security Group Module Input Variables
# =============================================================================
# All three variables are REQUIRED (no defaults) — the caller must supply them.
# =============================================================================


# -----------------------------------------------------------------------------
# project_name
# -----------------------------------------------------------------------------
# Used as a prefix for the security group's Name tag and resource name.
# Example: "op-demo" → security group named "op-demo-sg".
# -----------------------------------------------------------------------------
variable "project_name" { type = string }


# -----------------------------------------------------------------------------
# vpc_id
# -----------------------------------------------------------------------------
# The ID of the VPC in which the security group will be created.
# A security group is VPC-scoped; you cannot move it between VPCs.
# This value is wired in from the vpc module output: module.vpc.vpc_id.
# -----------------------------------------------------------------------------
variable "vpc_id" { type = string }


# -----------------------------------------------------------------------------
# ssh_ingress_cidr
# -----------------------------------------------------------------------------
# The CIDR block that is allowed to reach port 22 (SSH) on the EC2 instance.
# Best practice: use your exact public IP with a /32 mask (single host).
# Example: "1.2.3.4/32"
#
# NEVER set this to "0.0.0.0/0" in a real environment — bots scan port 22
# continuously and will attempt to brute-force login.
# -----------------------------------------------------------------------------
variable "ssh_ingress_cidr" {
  type        = string
  description = "CIDR allowed to SSH"
}
