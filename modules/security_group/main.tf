# =============================================================================
# modules/security_group/main.tf – Security Group Module Resources
# =============================================================================
# This module creates a single AWS Security Group that acts as a virtual
# firewall for the EC2 instance.
#
# Rules configured here:
#   INGRESS (inbound)
#     • Port 22  / TCP  – SSH, restricted to the caller's IP only
#     • Port 80  / TCP  – HTTP, open to the entire internet for demo purposes
#   EGRESS (outbound)
#     • All traffic     – unrestricted; EC2 can phone home, install packages, etc.
#
# IMPORTANT: In production, the HTTP rule should be tightened to a specific
# CIDR or replaced by a load-balancer security group with limited access.
# =============================================================================


# -----------------------------------------------------------------------------
# Resource: aws_security_group
# -----------------------------------------------------------------------------
# A Security Group is stateful: if you allow an inbound connection, the return
# traffic is automatically allowed without a separate egress rule.
#
# name        – displayed in the AWS Console; must be unique within the VPC.
# description – human-readable label; required by AWS (cannot be empty).
# vpc_id      – the VPC this SG belongs to; supplied by the caller via
#               module.vpc.vpc_id (cross-module reference).
# -----------------------------------------------------------------------------
resource "aws_security_group" "this" {
  name        = "${var.project_name}-sg"
  description = "Demo security group"
  vpc_id      = var.vpc_id # pins the SG to the correct VPC

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description     = egress.value.description
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
    }
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}
