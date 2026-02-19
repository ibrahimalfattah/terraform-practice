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

  # ---------------------------------------------------------------------------
  # Ingress rule 1: SSH (port 22)
  # ---------------------------------------------------------------------------
  # Allows inbound TCP on port 22 only from `ssh_ingress_cidr`.
  # Using /32 (a single host) means only your workstation can SSH in —
  # this is the minimal attack surface principle.
  #
  # from_port / to_port  – both 22 means exactly port 22 (no range)
  # protocol             – "tcp" (SSH uses TCP)
  # cidr_blocks          – list with one entry: the caller's personal IP/32
  # ---------------------------------------------------------------------------
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr] # e.g. ["1.2.3.4/32"]
  }

  # ---------------------------------------------------------------------------
  # Ingress rule 2: HTTP (port 80)
  # ---------------------------------------------------------------------------
  # Allows inbound HTTP from anywhere so you can test the Nginx welcome page
  # in a browser without extra configuration.
  #
  # cidr_blocks = ["0.0.0.0/0"] means ALL internet IPs are allowed.
  # For production, replace this with a load-balancer SG or HTTPS (443).
  # ---------------------------------------------------------------------------
  ingress {
    description = "HTTP for quick test"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open to the world — demo only
  }

  # ---------------------------------------------------------------------------
  # Egress rule: all outbound traffic
  # ---------------------------------------------------------------------------
  # Allows the EC2 instance to initiate connections to any IP on any port.
  # This is needed for: package updates, DNS lookups, AWS API calls, etc.
  #
  # protocol  = "-1"  →  all protocols (TCP, UDP, ICMP, …)
  # from_port = 0, to_port = 0  →  all ports (only meaningful when proto = -1)
  # ---------------------------------------------------------------------------
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"         # -1 = all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}
