resource "aws_lb" "this" {
  name               = "${var.project_name}-alb"
  load_balancer_type = var.load_balancer_type
  internal           = var.internal
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = { Name = "${var.project_name}-alb" }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.project_name}-tg"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = var.hc_enabled
    path                = var.hc_path
    matcher             = var.hc_matcher
    interval            = var.hc_interval
    timeout             = var.hc_timeout
    healthy_threshold   = var.hc_healthy_threshold
    unhealthy_threshold = var.hc_unhealthy_threshold
  }

  tags = { Name = "${var.project_name}-tg" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = var.listener_type
    target_group_arn = aws_lb_target_group.this.arn
  }
}
