data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source               = "../modules/vpc"
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  azs                  = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_dns_support        = var.enable_dns_support
  enable_dns_hostnames      = var.enable_dns_hostnames
  map_public_ip_on_launch   = var.map_public_ip_on_launch
  public_route_destination  = var.public_route_destination
  eip_domain                = var.eip_domain
  private_route_destination = var.private_route_destination
}

module "security" {
  source                = "../modules/security"
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  alb_ingress_rules     = var.alb_ingress_rules
  alb_egress_rules      = var.alb_egress_rules
  instance_egress_rules = var.instance_egress_rules
  instance_ingress_rules = [
    {
      description     = "HTTP from ALB SG"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.security.alb_sg_id]
    }
  ]
}

module "alb" {
  source            = "../modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id

  load_balancer_type     = var.load_balancer_type
  internal               = var.alb_internal
  tg_port                = var.tg_port
  tg_protocol            = var.tg_protocol
  hc_enabled             = var.hc_enabled
  hc_path                = var.hc_path
  hc_matcher             = var.hc_matcher
  hc_interval            = var.hc_interval
  hc_timeout             = var.hc_timeout
  hc_healthy_threshold   = var.hc_healthy_threshold
  hc_unhealthy_threshold = var.hc_unhealthy_threshold
  listener_port          = var.listener_port
  listener_protocol      = var.listener_protocol
  listener_type          = var.listener_type
}

module "asg" {
  source             = "../modules/asg"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_sg_id     = module.security.instance_sg_id
  target_group_arn   = module.alb.target_group_arn
  instance_type      = var.instance_type
  asg_min            = var.asg_min
  asg_desired        = var.asg_desired
  asg_max            = var.asg_max

  ami_owners                    = var.ami_owners
  ami_filter_name               = var.ami_filter_name
  ami_filter_values             = var.ami_filter_values
  asg_health_check_type         = var.asg_health_check_type
  asg_health_check_grace_period = var.asg_health_check_grace_period
  lt_version                    = var.lt_version
  tag_resource_type             = var.tag_resource_type
  tag_key_name                  = var.tag_key_name
  propagate_at_launch           = var.propagate_at_launch
  policy_type                   = var.policy_type
  predefined_metric_type        = var.predefined_metric_type
  target_value                  = var.cpu_target_value
  user_data                     = var.user_data
}
