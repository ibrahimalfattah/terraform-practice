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
# instance_public_ip
# -----------------------------------------------------------------------------
# The public IPv4 address assigned to the EC2 instance.
# Available only because the instance sits in a PUBLIC subnet with
# `map_public_ip_on_launch = true`.
# Use this IP to:
#   • SSH into the server:  ssh -i ~/.ssh/id_rsa ec2-user@<ip>
#   • Open Nginx in a browser: http://<ip>
# -----------------------------------------------------------------------------
output "instance_public_ip" {
  value = module.ec2.public_ip # sourced from modules/ec2/outputs.tf → aws_instance.this.public_ip
}
