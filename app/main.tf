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
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]

  # Two private subnets (no direct internet access) for future use
  # (e.g. RDS, internal services)
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
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
module "sg" {
  source       = "../modules/security_group"
  project_name = var.project_name

  # vpc_id is taken directly from the vpc module output – no hard-coding needed
  vpc_id = module.vpc.vpc_id

  # Restricts SSH access to only the caller's IP address for security
  ssh_ingress_cidr = var.my_ip_cidr
}


# -----------------------------------------------------------------------------
# Module: ec2
# Source: ../modules/ec2
# -----------------------------------------------------------------------------
# Launches a single EC2 instance pre-configured with Nginx:
#   • Looks up the latest Amazon Linux 2023 AMI automatically (data source)
#   • Uploads your local SSH public key as an EC2 Key Pair
#   • Runs a user-data script on first boot to install & start Nginx
#
# Inputs
#   project_name       – Name-tag prefix
#   subnet_id          – the first public subnet from the vpc module
#                        (public_subnet_ids[0]) so the instance gets a public IP
#   security_group_ids – list containing the SG created by the sg module;
#                        wrapping in a list lets the module accept multiple SGs
#   instance_type      – EC2 family/size (default: t3.micro, set in tfvars)
#   public_key_path    – local filesystem path to your .pub SSH key
#
# Outputs consumed here
#   module.ec2.public_ip → exposed as a root-level output (see outputs.tf)
# -----------------------------------------------------------------------------
module "ec2" {
  source       = "../modules/ec2"
  project_name = var.project_name

  # Place the instance into the first public subnet so it receives a public IP
  subnet_id = module.vpc.public_subnet_ids[0]

  # Wrap in a list because the EC2 resource accepts a list of SG IDs
  security_group_ids = [module.sg.security_group_id]

  instance_type   = var.instance_type
  public_key_path = var.public_key_path
}
