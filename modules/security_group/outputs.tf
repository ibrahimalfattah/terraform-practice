# =============================================================================
# modules/security_group/outputs.tf – Security Group Module Outputs
# =============================================================================
# Exposes the newly created security group's ID so the caller can attach it
# to EC2 instances, load balancers, or other resources that require an SG.
# =============================================================================


# -----------------------------------------------------------------------------
# security_group_id
# -----------------------------------------------------------------------------
# The AWS-assigned unique ID of the security group (format: "sg-0abc1234…").
# Consumed by the root module and passed into the ec2 module:
#   security_group_ids = [module.sg.security_group_id]
# The ec2 resource accepts a *list* of SG IDs, so it is wrapped in a list
# at the call site, allowing multiple SGs to be attached in the future.
# -----------------------------------------------------------------------------
output "security_group_id" {
  value = aws_security_group.this.id
}
