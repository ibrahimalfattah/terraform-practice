# =============================================================================
# terraform.tfvars – Root Module Variable Values
# =============================================================================
# This file supplies concrete values for the input variables declared in
# variables.tf.  Terraform automatically loads *.tfvars files found in the
# working directory, so no -var-file flag is needed.
#
# SECURITY NOTE
# -------------
# terraform.tfvars is committed here for demo purposes only.
# In real projects, files containing secrets or personal IPs should be listed
# in .gitignore and NOT committed to version control.  Use environment
# variables (TF_VAR_*) or a secrets manager instead.
# =============================================================================

# The AWS region where all infrastructure will be created.
# eu-north-1 = Stockholm (low latency for EU, often cheaper spot instances).
aws_region = "eu-north-1"

# Short prefix applied to the Name tag of every resource created.
# Makes it easy to identify all project resources in the AWS Console.
project_name = "op-demo"

# YOUR public IP address in /32 CIDR notation.
# Restricts SSH (port 22) to only this IP — never use 0.0.0.0/0 here.
# Update this with your real IP: curl -s ifconfig.me
my_ip_cidr = "1.2.3.4/32"

# EC2 instance size.  t3.micro is AWS Free-Tier eligible (750 hrs/month).
# Change to a larger type (e.g. t3.small) for heavier workloads.
instance_type = "t3.micro"

# Path to the local SSH *public* key that will be uploaded to AWS.
# The matching private key (~/.ssh/id_rsa) is used to SSH into the instance.
public_key_path = "~/.ssh/id_rsa.pub"
