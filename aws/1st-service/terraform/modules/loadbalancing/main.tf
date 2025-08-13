locals {
  name_alb = "${var.project_name}-${var.environment}-alb"
  name_tg  = "${var.project_name}-${var.environment}-tg"
}

resource "aws_lb" "this" {
  name               = local.name_alb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.deletion_protection
  idle_timeout               = var.idle_timeout

  tags = { Name = local.name_alb, Environment = var.environment, Project = var.project_name, ManagedBy = "Terraform" }
}

resource "aws_lb_target_group" "this" {
  name        = local.name_tg
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = var.health_check_matcher
  }

  tags = {
    Name        = local.name_tg,
    Environment = var.environment,
    Project     = var.project_name
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.target_instance_id
  port             = var.target_port
}
