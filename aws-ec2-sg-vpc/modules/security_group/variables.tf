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
# ingress_rules
# -----------------------------------------------------------------------------
# A list of objects defining ingress rules for the security group.
# -----------------------------------------------------------------------------
variable "ingress_rules" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  description = "List of ingress rules"
  default     = []
}

# -----------------------------------------------------------------------------
# egress_rules
# -----------------------------------------------------------------------------
# A list of objects defining egress rules for the security group.
# -----------------------------------------------------------------------------
variable "egress_rules" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  description = "List of egress rules"
  default     = []
}
