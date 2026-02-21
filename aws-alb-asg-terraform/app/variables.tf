variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "project_name" {
  type    = string
  default = "alb-asg-demo"
}

variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.40.1.0/24", "10.40.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.40.11.0/24", "10.40.12.0/24"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "asg_min" {
  type    = number
  default = 2
}

variable "asg_desired" {
  type    = number
  default = 2
}

variable "asg_max" {
  type    = number
  default = 4
}

# --- VPC variables ---
variable "enable_dns_support" { default = true }
variable "enable_dns_hostnames" { default = true }
variable "map_public_ip_on_launch" { default = true }
variable "public_route_destination" { default = "0.0.0.0/0" }
variable "eip_domain" { default = "vpc" }
variable "private_route_destination" { default = "0.0.0.0/0" }

variable "alb_ingress_rules" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = [
    {
      description = "HTTP from internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "alb_egress_rules" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = [
    {
      description = "All outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "instance_ingress_rules" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  # The security_groups value will require module.security.alb_sg_id 
  # so we will construct this list in app/main.tf directly.
  default = []
}

variable "instance_egress_rules" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = [
    {
      description = "All outbound (via NAT)"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# --- ALB variables ---
variable "load_balancer_type" { default = "application" }
variable "alb_internal" { default = false }
variable "tg_port" { default = 80 }
variable "tg_protocol" { default = "HTTP" }
variable "hc_enabled" { default = true }
variable "hc_path" { default = "/" }
variable "hc_matcher" { default = "200-399" }
variable "hc_interval" { default = 20 }
variable "hc_timeout" { default = 5 }
variable "hc_healthy_threshold" { default = 2 }
variable "hc_unhealthy_threshold" { default = 2 }
variable "listener_port" { default = 80 }
variable "listener_protocol" { default = "HTTP" }
variable "listener_type" { default = "forward" }

# --- ASG variables ---
variable "ami_owners" { default = ["amazon"] }
variable "ami_filter_name" { default = "name" }
variable "ami_filter_values" { default = ["al2023-ami-*-x86_64"] }
variable "asg_health_check_type" { default = "ELB" }
variable "asg_health_check_grace_period" { default = 90 }
variable "lt_version" { default = "$Latest" }
variable "tag_resource_type" { default = "instance" }
variable "tag_key_name" { default = "Name" }
variable "propagate_at_launch" { default = true }
variable "policy_type" { default = "TargetTrackingScaling" }
variable "predefined_metric_type" { default = "ASGAverageCPUUtilization" }
variable "cpu_target_value" { default = 50.0 }

variable "user_data" {
  type        = string
  description = "User data script for ASG instances"
  default     = <<-EOF
    #!/bin/bash
    set -e

    dnf -y update
    dnf -y install nginx

    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

    cat > /usr/share/nginx/html/index.html <<HTML
    <html>
      <head><title>alb-asg-demo</title></head>
      <body style="font-family: Arial;">
        <h1>alb-asg-demo</h1>
        <p>Served by: <b>$INSTANCE_ID</b></p>
        <p>AZ: <b>$AZ</b></p>
      </body>
    </html>
    HTML

    systemctl enable nginx
    systemctl restart nginx
  EOF
}
