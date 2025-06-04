# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Data source for current AWS region
data "aws_region" "current" {}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# Create Elastic IPs for NLB
resource "aws_eip" "nlb" {
  for_each = toset(var.public_subnet_ids)
  
  domain = "vpc"
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-nlb-eip-${each.key}"
    }
  )
}

# Create Network Load Balancer
resource "aws_lb" "network" {
  name               = "${var.environment}-${var.project_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  
  dynamic "subnet_mapping" {
    for_each = aws_eip.nlb
    
    content {
      subnet_id     = subnet_mapping.key
      allocation_id = subnet_mapping.value.id
    }
  }
  
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-nlb"
    }
  )
}

# Create TCP target group
resource "aws_lb_target_group" "tcp" {
  name        = "${var.environment}-${var.project_name}-tcp"
  port        = var.tcp_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    enabled             = true
    protocol            = "TCP"
    port               = "traffic-port"
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval           = var.health_check_interval
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-tcp"
    }
  )
}

# Create UDP target group
resource "aws_lb_target_group" "udp" {
  name        = "${var.environment}-${var.project_name}-udp"
  port        = var.udp_port
  protocol    = "UDP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    enabled             = true
    protocol            = "TCP"
    port               = var.udp_health_check_port
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval           = var.health_check_interval
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-udp"
    }
  )
}

# Create TLS target group
resource "aws_lb_target_group" "tls" {
  name        = "${var.environment}-${var.project_name}-tls"
  port        = var.tls_port
  protocol    = "TLS"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    enabled             = true
    protocol            = "TCP"
    port               = "traffic-port"
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval           = var.health_check_interval
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-tls"
    }
  )
}

# Create TCP listener
resource "aws_lb_listener" "tcp" {
  load_balancer_arn = aws_lb.network.arn
  port              = var.tcp_port
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp.arn
  }
}

# Create UDP listener
resource "aws_lb_listener" "udp" {
  load_balancer_arn = aws_lb.network.arn
  port              = var.udp_port
  protocol          = "UDP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.udp.arn
  }
}

# Create TLS listener
resource "aws_lb_listener" "tls" {
  load_balancer_arn = aws_lb.network.arn
  port              = var.tls_port
  protocol          = "TLS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tls.arn
  }
}

# Create CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  for_each = {
    tcp = aws_lb_target_group.tcp.arn_suffix
    udp = aws_lb_target_group.udp.arn_suffix
    tls = aws_lb_target_group.tls.arn_suffix
  }
  
  alarm_name          = "${var.environment}-${var.project_name}-nlb-${each.key}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/NetworkELB"
  period             = "300"
  statistic          = "Average"
  threshold          = "0"
  alarm_description  = "Unhealthy hosts count is greater than 0 for ${each.key} target group"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    TargetGroup  = each.value
    LoadBalancer = aws_lb.network.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "tcp_reset" {
  alarm_name          = "${var.environment}-${var.project_name}-nlb-tcp-reset"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TCP_Reset_Count"
  namespace           = "AWS/NetworkELB"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.tcp_reset_threshold
  alarm_description  = "High TCP reset count"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    LoadBalancer = aws_lb.network.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "tls_error" {
  alarm_name          = "${var.environment}-${var.project_name}-nlb-tls-error"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TLS_Error_Count"
  namespace           = "AWS/NetworkELB"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.tls_error_threshold
  alarm_description  = "High TLS error count"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    LoadBalancer = aws_lb.network.arn_suffix
  }
}

# Create Route53 record
resource "aws_route53_record" "nlb" {
  count = var.create_dns_record ? 1 : 0
  
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"
  
  alias {
    name                   = aws_lb.network.dns_name
    zone_id                = aws_lb.network.zone_id
    evaluate_target_health = true
  }
} 