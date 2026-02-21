# =============================================================================
# modules/ec2/main.tf – EC2 Module Resources & Data Sources
# =============================================================================
# This module provisions a single EC2 instance pre-configured to run Nginx.
#
#   Data sources
#     aws_ami             – looks up the latest Amazon Linux 2023 AMI dynamically
#
#   Resources (in dependency order)
#     aws_key_pair        – uploads the local SSH public key to AWS
#     aws_instance        – the virtual machine itself
# =============================================================================


# -----------------------------------------------------------------------------
# Data Source: aws_ami
# -----------------------------------------------------------------------------
# Queries the AWS EC2 AMI catalogue to find the most recent Amazon Linux 2023
# image so we never have to hard-code an AMI ID (which is region-specific and
# changes with every OS update).
#
# most_recent = true   – if multiple AMIs match the filter, pick the newest one.
# owners              – restrict results to AMIs published by Amazon's own AWS
#                       account (prevents accidentally picking a third-party AMI).
#
# filter block (name = "name", values = ["al2023-ami-*-x86_64"])
#   Matches the AMI name pattern used by Amazon Linux 2023 for x86-64 (64-bit)
#   instances.  The wildcard "*" matches any version string in the middle.
#   If you need ARM (Graviton), change "x86_64" to "arm64".
#
# Result used as:
#   data.aws_ami.amazon_linux.id  →  the AMI ID (e.g. "ami-0abc1234…")
# -----------------------------------------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # only trust Amazon-published images

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"] # Amazon Linux 2023, 64-bit x86
  }
}


# -----------------------------------------------------------------------------
# Resource: aws_key_pair
# -----------------------------------------------------------------------------
# Uploads your local SSH public key to AWS so the EC2 instance can be
# configured to accept it for authentication.
#
# key_name   – the name visible in the AWS Console under EC2 → Key Pairs.
#              Prefixed with project_name for easy identification.
# public_key – reads the file at `var.public_key_path` (e.g. ~/.ssh/id_rsa.pub)
#              using the built-in `file()` function.
#
# The PRIVATE key (~/.ssh/id_rsa) stays on your local machine and is NEVER
# sent to AWS — that is normal asymmetric key cryptography.
#
# To SSH after apply:
#   ssh -i ~/.ssh/id_rsa ec2-user@<instance_public_ip>
# -----------------------------------------------------------------------------
resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path) # reads the .pub file at plan/apply time
}


# -----------------------------------------------------------------------------
# Resource: aws_instance
# -----------------------------------------------------------------------------
# Launches a single EC2 virtual machine instance.
#
# ami                    – the AMI ID from the data source above; ensures
#                          we always get the latest Amazon Linux 2023 image.
# instance_type          – hardware profile (CPU/RAM); set via var.instance_type.
# subnet_id              – which subnet the instance lives in; must be a public
#                          subnet so the instance gets a public IP.
# vpc_security_group_ids – list of SG IDs controlling inbound/outbound traffic.
# key_name               – links the instance to the key pair uploaded above.
#
# user_data (heredoc BASH script)
# --------------------------------
# Runs automatically on the FIRST boot of the instance (via cloud-init):
#   1. `dnf update -y`         – updates all installed packages to latest versions
#   2. `dnf install -y nginx`  – installs the Nginx web server
#   3. `systemctl enable nginx`– configures Nginx to start on every reboot
#   4. `systemctl start nginx` – starts Nginx immediately on this boot
#   5. `echo … > index.html`   – replaces Nginx's default page with a custom
#                                 message showing the project name
#
# After apply, give the instance ~60 seconds to finish the user_data script,
# then open:  http://<instance_public_ip>  to see the custom page.
# -----------------------------------------------------------------------------
resource "aws_instance" "this" {
  ami                    = data.aws_ami.amazon_linux.id   # latest AL2023 AMI
  instance_type          = var.instance_type              # e.g. "t3.micro"
  subnet_id              = var.subnet_id                  # must be a public subnet
  vpc_security_group_ids = var.security_group_ids         # controls allowed traffic
  key_name               = aws_key_pair.this.key_name     # enables SSH login

  # Bootstrap script executed on first boot by cloud-init
  user_data = var.user_data

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
