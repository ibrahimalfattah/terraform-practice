# =============================================================================
# modules/ec2/variables.tf – EC2 Module Input Variables
# =============================================================================
# All variables here are REQUIRED (no defaults) — the caller must provide them.
# They are fed in from the root module's main.tf via the ec2 module block.
# =============================================================================


# -----------------------------------------------------------------------------
# project_name
# -----------------------------------------------------------------------------
# Short identifier used as a prefix in Name tags and resource names
# (e.g. key pair name, instance Name tag).
# Example: "op-demo" → key pair "op-demo-key", instance Name "op-demo-ec2".
# -----------------------------------------------------------------------------
variable "project_name" { type = string }


# -----------------------------------------------------------------------------
# subnet_id
# -----------------------------------------------------------------------------
# The ID of the subnet where the EC2 instance will be launched.
# Must be a PUBLIC subnet (i.e. one with map_public_ip_on_launch = true
# and an Internet Gateway route) so the instance receives a public IP address
# and can be reached from the internet.
#
# Comes from: module.vpc.public_subnet_ids[0]
# -----------------------------------------------------------------------------
variable "subnet_id" { type = string }


# -----------------------------------------------------------------------------
# security_group_ids
# -----------------------------------------------------------------------------
# A list of Security Group IDs to attach to the instance.
# AWS allows multiple SGs per instance; using a list makes future expansion
# easy (e.g. add an ALB-to-instance SG without changing this module).
#
# Comes from: [module.sg.security_group_id]  (wrapped in a list at call site)
# -----------------------------------------------------------------------------
variable "security_group_ids" { type = list(string) }


# -----------------------------------------------------------------------------
# instance_type
# -----------------------------------------------------------------------------
# Defines the EC2 instance hardware profile (vCPU count, RAM, network speed).
# Examples:
#   "t3.micro"  – 2 vCPU, 1 GiB  – free-tier eligible in many regions
#   "t3.small"  – 2 vCPU, 2 GiB
#   "m5.large"  – 2 vCPU, 8 GiB  – for production workloads
# Select based on cost and target workload requirements.
# -----------------------------------------------------------------------------
variable "instance_type" { type = string }


# -----------------------------------------------------------------------------
# public_key_path
# -----------------------------------------------------------------------------
# Filesystem path (on the machine running Terraform) to the SSH public key
# file (the .pub file).  The `file()` function in main.tf reads this file
# and uploads its content to AWS as an EC2 Key Pair.
#
# Use the matching private key to SSH:
#   ssh -i ~/.ssh/id_rsa ec2-user@<public_ip>
# -----------------------------------------------------------------------------
variable "public_key_path" {
  type        = string
  description = "Path to SSH public key"
}


# -----------------------------------------------------------------------------
# user_data
# -----------------------------------------------------------------------------
# The bootstrap script executed on first boot by cloud-init.
# -----------------------------------------------------------------------------
variable "user_data" {
  type        = string
  description = "The bootstrap script to run on EC2 startup"
}
