data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = var.ami_filter_name
    values = var.ami_filter_values
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.instance_sg_id]

  user_data = base64encode(var.user_data)

  tag_specifications {
    resource_type = var.tag_resource_type
    tags = {
      (var.tag_key_name) = "${var.project_name}-asg-instance"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.project_name}-asg"
  min_size                  = var.asg_min
  desired_capacity          = var.asg_desired
  max_size                  = var.asg_max
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = var.asg_health_check_type
  health_check_grace_period = var.asg_health_check_grace_period

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = var.lt_version
  }

  tag {
    key                 = var.tag_key_name
    value               = "${var.project_name}-asg"
    propagate_at_launch = var.propagate_at_launch
  }
}

# Target tracking scaling on average ASG CPU
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${var.project_name}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = var.policy_type

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.predefined_metric_type
    }
    target_value = var.target_value
  }
}
