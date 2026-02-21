# =============================================================================
# modules/vpc/outputs.tf – VPC Module Outputs
# =============================================================================
# Outputs are the values this module "returns" to its caller.
# The root module (app/main.tf) reads these to wire the VPC into other modules
# (e.g. security_group needs vpc_id; ec2 needs a public_subnet_id).
#
# Callers reference outputs using the syntax:
#   module.<module_label>.<output_name>
# e.g.  module.vpc.vpc_id
# =============================================================================


# -----------------------------------------------------------------------------
# vpc_id
# -----------------------------------------------------------------------------
# The AWS-assigned unique ID of the VPC (format: "vpc-0abc1234…").
# Used by:
#   • The security_group module  → to place the SG inside this VPC
#   • The ec2 module (indirectly) → via the SG and subnet IDs
# -----------------------------------------------------------------------------
output "vpc_id" {
  value = aws_vpc.this.id
}


# -----------------------------------------------------------------------------
# public_subnet_ids
# -----------------------------------------------------------------------------
# A list of IDs for every public subnet created by this module.
# Built with a for-expression that iterates over aws_subnet.public (a list of
# resource instances because count was used) and collects each subnet's .id.
#
# Callers can index into this list:
#   module.vpc.public_subnet_ids[0]  →  first public subnet (used by ec2 module)
# -----------------------------------------------------------------------------
output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id] # ["subnet-aaa", "subnet-bbb"]
}


# -----------------------------------------------------------------------------
# private_subnet_ids
# -----------------------------------------------------------------------------
# A list of IDs for every private subnet created by this module.
# Not consumed by any root-module resource currently, but exposed so callers
# can attach future resources (e.g. RDS, ECS tasks) to private subnets without
# modifying this module.
# -----------------------------------------------------------------------------
output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id] # ["subnet-ccc", "subnet-ddd"]
}
