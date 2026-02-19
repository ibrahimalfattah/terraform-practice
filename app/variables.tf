# =============================================================================
# variables.tf – Root Module Input Variables
# =============================================================================
# Variables declared here are the public interface of the root module.
# Values are supplied via terraform.tfvars (or -var flags / environment vars).
# Every variable used by child modules that may differ per environment should
# be declared here and threaded in through main.tf.
# =============================================================================


# -----------------------------------------------------------------------------
# aws_region
# -----------------------------------------------------------------------------
# Controls which AWS region all resources are deployed into.
# Example: "eu-north-1" (Stockholm), "us-east-1" (N. Virginia)
# This is passed to the provider block in providers.tf via `var.aws_region`.
# -----------------------------------------------------------------------------
variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
}


# -----------------------------------------------------------------------------
# project_name
# -----------------------------------------------------------------------------
# A short identifier used as a prefix in the Name tag of every resource
# (VPC, subnets, security group, EC2 instance, key pair, etc.).
# Keeping resources tagged makes cost allocation and cleanup much easier.
# Example: "op-demo"  →  tags like "op-demo-vpc", "op-demo-sg", etc.
# -----------------------------------------------------------------------------
variable "project_name" {
  type        = string
  description = "Project name prefix for tagging"
}


# -----------------------------------------------------------------------------
# my_ip_cidr
# -----------------------------------------------------------------------------
# Your current public IP address in CIDR notation, used to lock down SSH
# access so only your machine can reach port 22 on the EC2 instance.
# Tip: run `curl -s ifconfig.me` and append /32, e.g. "1.2.3.4/32".
# Using /32 means exactly one IP; never use 0.0.0.0/0 here in production.
# -----------------------------------------------------------------------------
variable "my_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR format for SSH access, e.g. 1.2.3.4/32"
}


# -----------------------------------------------------------------------------
# instance_type
# -----------------------------------------------------------------------------
# The EC2 instance family and size.  Defaults to t3.micro (Free-Tier eligible
# in many regions).  Override in terraform.tfvars for larger workloads.
# Examples: "t3.micro", "t3.small", "m5.large"
# -----------------------------------------------------------------------------
variable "instance_type" {
  type    = string
  default = "t3.micro"
  # No description set here; the default makes the intent clear.
  # Consider adding: description = "EC2 instance type for the demo server"
}


# -----------------------------------------------------------------------------
# public_key_path
# -----------------------------------------------------------------------------
# Filesystem path (on the machine running Terraform) to the SSH public key
# that will be uploaded to AWS as an EC2 Key Pair.
# The corresponding private key lets you SSH into the instance:
#   ssh -i ~/.ssh/id_rsa ec2-user@<instance_public_ip>
# The `file()` function in the ec2 module reads this path at plan/apply time.
# -----------------------------------------------------------------------------
variable "public_key_path" {
  type        = string
  description = "Path to your SSH public key, e.g. ~/.ssh/id_rsa.pub"
}
