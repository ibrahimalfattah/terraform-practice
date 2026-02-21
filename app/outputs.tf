# =============================================================================
# outputs.tf – Root Module Outputs
# =============================================================================
# Outputs are values that Terraform prints to the terminal after a successful
# `terraform apply`.  They are also readable by other configurations that call
# this root module with `terraform_remote_state`, or useful as quick references
# when you need to SSH into the instance or look up network IDs.
#
# Convention: root outputs bubble up values from child module outputs.
# =============================================================================


# -----------------------------------------------------------------------------
# vpc_id
# -----------------------------------------------------------------------------
# The unique AWS identifier of the VPC created by the vpc module
# (format: "vpc-0abc1234...").
# Useful for: referencing the VPC in the AWS Console, cross-stack lookups, or
# debugging when you need to confirm which VPC your resources belong to.
# -----------------------------------------------------------------------------
output "vpc_id" {
  value = module.vpc.vpc_id # sourced from modules/vpc/outputs.tf → aws_vpc.this.id
}


# -----------------------------------------------------------------------------
# public_subnet_ids
# -----------------------------------------------------------------------------
# A list of IDs for every public subnet created by the vpc module.
# One element per entry in `public_subnet_cidrs` (currently two subnets).
# Useful for: quickly retrieving subnet IDs to attach more resources later
# (e.g. a load balancer, another EC2 instance, or an EKS node group).
# -----------------------------------------------------------------------------
output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids # list → ["subnet-aaa", "subnet-bbb"]
}


# -----------------------------------------------------------------------------
# public_instance_public_ip
# -----------------------------------------------------------------------------
# The public IPv4 address assigned to the public EC2 instance.
# -----------------------------------------------------------------------------
output "public_instance_public_ip" {
  value = module.public_ec2.public_ip
}

# -----------------------------------------------------------------------------
# private_instance_private_ip
# -----------------------------------------------------------------------------
# The private IPv4 address assigned to the private EC2 instance.
# -----------------------------------------------------------------------------
output "private_instance_private_ip" {
  value = module.private_ec2.private_ip
}
