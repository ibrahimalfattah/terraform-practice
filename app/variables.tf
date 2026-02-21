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
# ingress_rules
# -----------------------------------------------------------------------------
# A list of objects defining ingress rules for the application.
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
  description = "List of dynamic ingress rules to apply"
  default     = []
}

# -----------------------------------------------------------------------------
# egress_rules
# -----------------------------------------------------------------------------
# A list of objects defining egress rules for the application.
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
  description = "List of dynamic egress rules to apply"
  default     = []
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


# -----------------------------------------------------------------------------
# user_data
# -----------------------------------------------------------------------------
# The bootstrap script to run on EC2 startup.
# -----------------------------------------------------------------------------
variable "user_data" {
  type        = string
  description = "The bootstrap script to run on EC2 startup"
}
