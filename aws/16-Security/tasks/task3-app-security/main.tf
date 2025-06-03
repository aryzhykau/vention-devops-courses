provider "aws" {
  region = var.aws_region
}

# WAF Web ACL
resource "aws_wafv2_web_acl" "main" {
  count       = var.enable_waf ? 1 : 0
  name        = "${var.project_name}-web-acl"
  description = "WAF Web ACL with security rules"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.waf_block_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name               = rule.value.name
        sampled_requests_enabled  = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name               = "${var.project_name}-web-acl"
    sampled_requests_enabled  = true
  }

  tags = var.tags
}

# SSL Certificate
resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  validation_method        = "DNS"
  subject_alternative_names = var.alternative_names

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = var.subnet_ids

  enable_deletion_protection = false

  tags = var.tags
}

# ALB Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.main.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
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
      Name = "${var.project_name}-alb-sg"
    }
  )
}

# Secrets Manager
resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.enable_secrets_manager ? { for s in var.secrets : s.name => s } : {}

  name        = "${var.project_name}/${each.value.name}"
  description = each.value.description

  tags = var.tags
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests" {
  count               = var.enable_monitoring && var.enable_waf ? 1 : 0
  alarm_name          = "${var.project_name}-waf-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "BlockedRequests"
  namespace          = "AWS/WAFV2"
  period             = "300"
  statistic          = "Sum"
  threshold          = "100"
  alarm_description  = "This metric monitors blocked requests by WAF"
  alarm_actions      = [aws_sns_topic.security_alerts[0].arn]

  dimensions = {
    WebACL = aws_wafv2_web_acl.main[0].name
    Region = var.aws_region
  }

  tags = var.tags
}

# SNS Topic for Security Alerts
resource "aws_sns_topic" "security_alerts" {
  count = var.enable_monitoring && var.alert_email != "" ? 1 : 0
  name  = "${var.project_name}-security-alerts"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "security_alerts" {
  count     = var.enable_monitoring && var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.security_alerts[0].arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Lambda Function for Security Headers
resource "aws_lambda_function" "security_headers" {
  count         = var.security_headers.hsts || var.security_headers.content_security_policy ? 1 : 0
  filename      = "${path.module}/lambda/security_headers.zip"
  function_name = "${var.project_name}-security-headers"
  role          = aws_iam_role.lambda_security_headers[0].arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  environment {
    variables = {
      SECURITY_HEADERS = jsonencode({
        hsts                    = var.security_headers.hsts
        content_security_policy = var.security_headers.content_security_policy
        x_frame_options         = var.security_headers.x_frame_options
        x_content_type_options  = var.security_headers.x_content_type_options
        referrer_policy        = var.security_headers.referrer_policy
      })
    }
  }

  tags = var.tags
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_security_headers" {
  count = var.security_headers.hsts || var.security_headers.content_security_policy ? 1 : 0
  name  = "${var.project_name}-lambda-security-headers"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_security_headers" {
  count             = var.security_headers.hsts || var.security_headers.content_security_policy ? 1 : 0
  name              = "/aws/lambda/${aws_lambda_function.security_headers[0].function_name}"
  retention_in_days = 7

  tags = var.tags
}

# Lambda Basic Execution Role Policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count      = var.security_headers.hsts || var.security_headers.content_security_policy ? 1 : 0
  role       = aws_iam_role.lambda_security_headers[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
} 