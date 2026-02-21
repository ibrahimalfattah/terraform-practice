# =============================================================================
# modules/ec2/outputs.tf – EC2 Module Outputs
# =============================================================================
# Exposes information about the created EC2 instance to the caller so it can
# be surfaced to the user or used by other parts of the configuration.
# =============================================================================


# -----------------------------------------------------------------------------
# public_ip
# -----------------------------------------------------------------------------
# The public IPv4 address assigned to the EC2 instance.
# This address is available because the instance is in a public subnet with
# `map_public_ip_on_launch = true` (set in the vpc module).
#
# Consumed by the root module's outputs.tf:
#   output "instance_public_ip" { value = module.ec2.public_ip }
#
# After `terraform apply` completes, use this IP to:
#   • SSH:     ssh -i ~/.ssh/id_rsa ec2-user@<public_ip>
#   • Browser: http://<public_ip>  to see the Nginx welcome page
#
# Note: If the instance is stopped and started again, the public IP can change
# (EIP / Elastic IP is needed for a persistent public address).
# -----------------------------------------------------------------------------
output "public_ip" {
  value = aws_instance.this.public_ip
}

# -----------------------------------------------------------------------------
# private_ip
# -----------------------------------------------------------------------------
output "private_ip" {
  value = aws_instance.this.private_ip
}
