# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Data source for ELB service account
data "aws_elb_service_account" "main" {}

# Data source for current AWS region
data "aws_region" "current" {}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# Create S3 bucket for ALB access logs
resource "aws_s3_bucket" "logs" {
  bucket = "${var.environment}-${var.project_name}-alb-logs-${data.aws_caller_identity.current.account_id}"
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-alb-logs"
    }
  )
}

# Configure S3 bucket for versioning
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure S3 bucket lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  rule {
    id     = "log_expiration"
    status = "Enabled"
    
    expiration {
      days = var.log_retention_days
    }
  }
}

# Configure S3 bucket policy for ALB access logs
resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action = "s3:PutObject"
        Resource = [
          "${aws_s3_bucket.logs.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = [
          "${aws_s3_bucket.logs.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = "s3:GetBucketAcl"
        Resource = [
          aws_s3_bucket.logs.arn
        ]
      }
    ]
  })
}

# Create security group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.environment}-${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP from Internet (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-alb-sg"
    }
  )
}

# Create security group for targets
resource "aws_security_group" "targets" {
  name        = "${var.environment}-${var.project_name}-targets-sg"
  description = "Security group for ALB targets"
  vpc_id      = var.vpc_id
  
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-targets-sg"
    }
  )
}

# Create Application Load Balancer
resource "aws_lb" "app" {
  name               = "${var.environment}-${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
  
  enable_deletion_protection = var.enable_deletion_protection
  
  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "alb-logs"
    enabled = true
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-alb"
    }
  )
}

# Create target group for API
resource "aws_lb_target_group" "api" {
  name        = "${var.environment}-${var.project_name}-api"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    enabled             = true
    path                = var.api_health_check_path
    port                = "traffic-port"
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    matcher             = var.api_health_check_matcher
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-api"
    }
  )
}

# Create target group for static content
resource "aws_lb_target_group" "static" {
  name        = "${var.environment}-${var.project_name}-static"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    enabled             = true
    path                = var.static_health_check_path
    port                = "traffic-port"
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    matcher             = var.static_health_check_matcher
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-static"
    }
  )
}

# Create HTTPS listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  
  default_action {
    type = "fixed-response"
    
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# Create HTTP listener (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type = "redirect"
    
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create listener rule for API
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
  
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# Create listener rule for static content
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 200
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.static.arn
  }
  
  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}

# Create CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  for_each = {
    api    = aws_lb_target_group.api.arn_suffix
    static = aws_lb_target_group.static.arn_suffix
  }
  
  alarm_name          = "${var.environment}-${var.project_name}-${each.key}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Average"
  threshold          = "0"
  alarm_description  = "Unhealthy hosts count is greater than 0 for ${each.key} target group"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    TargetGroup  = each.value
    LoadBalancer = aws_lb.app.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_5xx" {
  alarm_name          = "${var.environment}-${var.project_name}-alb-high-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.high_5xx_threshold
  alarm_description  = "High 5XX error rate from targets"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    LoadBalancer = aws_lb.app.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_4xx" {
  alarm_name          = "${var.environment}-${var.project_name}-alb-high-4xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.high_4xx_threshold
  alarm_description  = "High 4XX error rate from targets"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    LoadBalancer = aws_lb.app.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "${var.environment}-${var.project_name}-alb-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Average"
  threshold          = var.high_latency_threshold
  alarm_description  = "High target response time"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    LoadBalancer = aws_lb.app.arn_suffix
  }
}

# Create Route53 record
resource "aws_route53_record" "alb" {
  count = var.create_dns_record ? 1 : 0
  
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"
  
  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
} 