# =============================================================================
# modules/vpc/main.tf – VPC Module Resources & Data Sources
# =============================================================================
# This module creates the full networking stack needed for a two-tier app:
#
#   Data sources
#     aws_availability_zones  – auto-discovers AZs in the chosen region
#
#   Resources (in dependency order)
#     aws_vpc                      – the virtual network boundary
#     aws_internet_gateway         – gives the VPC a route to the internet
#     aws_subnet (public)          – public subnets, one per CIDR provided
#     aws_subnet (private)         – private subnets, one per CIDR provided
#     aws_route_table (public)     – route table for public subnets
#     aws_route                    – default route 0.0.0.0/0 → IGW
#     aws_route_table_association  – attaches route table to each public subnet
# =============================================================================


# -----------------------------------------------------------------------------
# Data Source: aws_availability_zones
# -----------------------------------------------------------------------------
# Queries AWS for the list of Availability Zones that are currently available
# (not in an outage / not opted-out) in the configured region.
#
# `state = "available"` filters out any AZs that are not ready for use.
#
# Result used below:
#   data.aws_availability_zones.available.names  →  ["eu-north-1a", "eu-north-1b", ...]
#
# By using a data source instead of hard-coding AZ names we keep the module
# region-agnostic — it will work in any region automatically.
# -----------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}


# -----------------------------------------------------------------------------
# Resource: aws_vpc
# -----------------------------------------------------------------------------
# Creates the Virtual Private Cloud — an isolated network in AWS.
# All other networking resources (subnets, IGW, etc.) are created inside it.
#
# cidr_block           – the overall IP address space (e.g. 10.10.0.0/16
#                         gives you 65 536 addresses to carve into subnets).
# enable_dns_support   – lets AWS resolve DNS names within the VPC (required
#                         for private DNS and AWS service endpoints).
# enable_dns_hostnames – assigns DNS hostnames to instances with public IPs
#                         (needed for `ssh ec2-user@<hostname>` to work).
#
# tags.Name – follows the pattern "<project_name>-vpc" for easy identification.
# -----------------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support  # allows AWS DNS resolver inside the VPC
  enable_dns_hostnames = var.enable_dns_hostnames  # gives public instances DNS hostnames

  tags = {
    Name = "${var.project_name}-vpc"
  }
}


# -----------------------------------------------------------------------------
# Resource: aws_internet_gateway
# -----------------------------------------------------------------------------
# Attaches an Internet Gateway (IGW) to the VPC.
# The IGW is the single exit/entry point for internet traffic in the VPC.
# Without it, resources in public subnets have IP addresses but no route out.
#
# vpc_id – the ID of the VPC we just created above (implicit dependency:
#           Terraform will create the VPC first, then the IGW).
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}


# -----------------------------------------------------------------------------
# Resource: aws_subnet (public) – count-based loop
# -----------------------------------------------------------------------------
# Creates one PUBLIC subnet for each CIDR in var.public_subnet_cidrs.
# `count` causes Terraform to create N copies of this resource block.
#
# count                   – number of subnets = number of CIDRs supplied
# cidr_block              – each iteration picks the next CIDR from the list
# availability_zone       – each subnet lands in a different AZ for HA
#                           (uses data.aws_availability_zones to stay dynamic)
# map_public_ip_on_launch – instances launched here automatically receive a
#                           public IPv4 address (this is what makes it "public")
#
# Note: count.index is 0-based (0, 1, 2, …), so +1 is used in the Name tag
#       to produce human-friendly names like "…-public-1", "…-public-2".
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs) # e.g. 2 → creates public-0 and public-1

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]        # "10.10.1.0/24", then "10.10.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index] # spread across AZs
  map_public_ip_on_launch = var.map_public_ip_on_launch # EC2 instances here get a public IP automatically

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}" # e.g. "op-demo-public-1"
  }
}


# -----------------------------------------------------------------------------
# Resource: aws_subnet (private) – count-based loop
# -----------------------------------------------------------------------------
# Creates one PRIVATE subnet for each CIDR in var.private_subnet_cidrs.
# These subnets do NOT have `map_public_ip_on_launch = true`, so instances
# launched here only get private IPs.
#
# Private subnets are typically used for databases, caches, or backend
# services that should not be directly reachable from the internet.
# (A NAT Gateway would be added later if outbound internet access is needed.)
# -----------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs) # e.g. 2 → creates private-0 and private-1

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-private-${count.index + 1}" # e.g. "op-demo-private-1"
  }
}


# -----------------------------------------------------------------------------
# Resource: aws_route_table (public)
# -----------------------------------------------------------------------------
# A route table holds routing rules that govern where traffic is sent.
# This one is dedicated to public subnets; the default route will be added
# via `aws_route` below to send all internet-bound traffic to the IGW.
# -----------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}


# -----------------------------------------------------------------------------
# Resource: aws_route (default internet route)
# -----------------------------------------------------------------------------
# Adds a single routing rule to the public route table:
#   destination 0.0.0.0/0 (all traffic)  →  target: Internet Gateway
#
# This is the rule that makes the public subnets truly "public" — without it,
# traffic would have nowhere to go outside the VPC.
#
# destination_cidr_block = "0.0.0.0/0" means "match any IP not in the VPC"
# gateway_id             = the IGW created earlier (implicit dependency)
# -----------------------------------------------------------------------------
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = var.destination_cidr_block          # catch-all: send to internet
  gateway_id             = aws_internet_gateway.this.id
}


# -----------------------------------------------------------------------------
# Resource: aws_route_table_association (public) – count-based loop
# -----------------------------------------------------------------------------
# Associates the public route table with every public subnet.
# Without this association, subnets use the VPC's implicit "main" route table
# which has no IGW route, so internet access would not work.
#
# One association is created per subnet (same count as aws_subnet.public).
# -----------------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public) # matches the number of public subnets

  subnet_id      = aws_subnet.public[count.index].id # bind each subnet…
  route_table_id = aws_route_table.public.id          # …to the public route table
}
