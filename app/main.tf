# =============================================================================
# main.tf – Root Module Entry Point
# =============================================================================
# This file is the central "glue" of the configuration.  It calls each child
# module in turn, passing values down to them and wiring their outputs together
# so that dependent modules receive the IDs they need.
#
# Execution order (Terraform resolves this via the dependency graph):
#   1. vpc   – creates the network foundation (VPC, subnets, routing)
#   2. sg    – creates a security group inside the VPC produced above
#   3. ec2   – launches an instance wired to the subnet and security group
# =============================================================================


# -----------------------------------------------------------------------------
# Module: vpc
# Source: ../modules/vpc
# -----------------------------------------------------------------------------
# Provisions the core networking layer:
#   • An AWS VPC with the given CIDR block
#   • Public subnets (one per CIDR supplied) with auto-assign public IPs
#   • Private subnets (one per CIDR supplied) without public IPs
#   • An Internet Gateway attached to the VPC
#   • A public route table with a default route (0.0.0.0/0 → IGW) and
#     associations to every public subnet
#
# Inputs
#   project_name         – used as a Name-tag prefix for every resource
#   vpc_cidr             – the overall IP space for the VPC (e.g. 10.10.0.0/16)
#   public_subnet_cidrs  – list of CIDRs, one public subnet is created per entry
#   private_subnet_cidrs – list of CIDRs, one private subnet per entry
#
# Outputs consumed here
#   module.vpc.vpc_id           → passed into the sg module
#   module.vpc.public_subnet_ids → index [0] passed into the ec2 module
# -----------------------------------------------------------------------------
module "vpc" {
  source       = "../modules/vpc"
  project_name = var.project_name

  vpc_cidr = "10.10.0.0/16"

  # Two public subnets spread across AZs for high-availability
  public_subnet_cidrs  = ["10.10.1.0/24"]

  # Two private subnets (no direct internet access) for future use
  # (e.g. RDS, internal services)
  private_subnet_cidrs = ["10.10.11.0/24"]
}


# -----------------------------------------------------------------------------
# Module: sg (Security Group)
# Source: ../modules/security_group
# -----------------------------------------------------------------------------
# Creates a single AWS Security Group attached to the VPC above.
# Rules defined inside the module:
#   • Ingress  port 22  (SSH)  – restricted to `my_ip_cidr` only
#   • Ingress  port 80  (HTTP) – open to the world (0.0.0.0/0) for testing
#   • Egress   all traffic     – unrestricted outbound
#
# Inputs
#   project_name     – Name-tag prefix
#   vpc_id           – wired from module.vpc.vpc_id (cross-module reference)
#   ssh_ingress_cidr – your personal public IP in CIDR notation (e.g. 1.2.3.4/32)
#
# Outputs consumed here
#   module.sg.security_group_id → passed into the ec2 module
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Module: public_sg (Security Group for Public EC2)
# -----------------------------------------------------------------------------
module "public_sg" {
  source       = "../modules/security_group"
  project_name = "${var.project_name}-public"
  vpc_id       = module.vpc.vpc_id

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
}

# -----------------------------------------------------------------------------
# Module: private_sg (Security Group for Private EC2)
# -----------------------------------------------------------------------------
module "private_sg" {
  source       = "../modules/security_group"
  project_name = "${var.project_name}-private"
  vpc_id       = module.vpc.vpc_id

  # Ingress from Public SG only
  ingress_rules = [
    {
      description     = "Allow all from Public EC2 SG"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      security_groups = [module.public_sg.security_group_id]
    }
  ]

  # Egress to Public SG only
  egress_rules = [
    {
      description     = "Allow all to Public EC2 SG"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      security_groups = [module.public_sg.security_group_id]
    }
  ]
}

# -----------------------------------------------------------------------------
# Module: public_ec2
# -----------------------------------------------------------------------------
module "public_ec2" {
  source       = "../modules/ec2"
  project_name = "${var.project_name}-public"
  subnet_id    = module.vpc.public_subnet_ids[0]

  security_group_ids = [module.public_sg.security_group_id]

  instance_type   = var.instance_type
  public_key_path = var.public_key_path
  user_data       = var.user_data
}

# -----------------------------------------------------------------------------
# Module: private_ec2
# -----------------------------------------------------------------------------
module "private_ec2" {
  source       = "../modules/ec2"
  project_name = "${var.project_name}-private"
  subnet_id    = module.vpc.private_subnet_ids[0]

  security_group_ids = [module.private_sg.security_group_id]

  instance_type   = var.instance_type
  public_key_path = var.public_key_path
  user_data       = "#!/bin/bash\necho 'Private Instance'"
}
