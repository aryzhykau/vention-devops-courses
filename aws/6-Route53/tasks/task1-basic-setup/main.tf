# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create Public Hosted Zone
resource "aws_route53_zone" "main" {
  name = var.domain_name
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Create A Record for main domain
resource "aws_route53_record" "main_a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"
  
  alias {
    name                   = var.alb_dns_name
    zone_id               = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Create AAAA Record for IPv6
resource "aws_route53_record" "main_aaaa" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "AAAA"
  
  alias {
    name                   = var.alb_dns_name
    zone_id               = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Create CNAME Record for www subdomain
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [var.domain_name]
}

# Create MX Records for email
resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = "3600"
  records = var.mx_records
}

# Create TXT Record for domain verification
resource "aws_route53_record" "txt" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = "300"
  records = var.txt_records
}

# Create Health Check for main website
resource "aws_route53_health_check" "main" {
  fqdn              = var.domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
  
  tags = {
    Name = "${var.project_name}-health-check"
  }
}

# Create Health Check for API endpoint
resource "aws_route53_health_check" "api" {
  fqdn              = "api.${var.domain_name}"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"
  
  tags = {
    Name = "${var.project_name}-api-health-check"
  }
}

# Create CloudWatch Log Group for DNS Query Logging
resource "aws_cloudwatch_log_group" "dns_query_logs" {
  name              = "/aws/route53/${var.domain_name}"
  retention_in_days = 30
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Create CloudWatch Log Resource Policy
resource "aws_cloudwatch_log_resource_policy" "route53_query_logging" {
  policy_name = "route53-query-logging-policy"
  
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "route53.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.dns_query_logs.arn}:*"
      }
    ]
  })
}

# Enable Query Logging
resource "aws_route53_query_log" "main" {
  depends_on = [aws_cloudwatch_log_resource_policy.route53_query_logging]
  
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.dns_query_logs.arn
  zone_id                  = aws_route53_zone.main.zone_id
}

# Create CloudWatch Alarm for Health Check
resource "aws_cloudwatch_metric_alarm" "health_check_alarm" {
  alarm_name          = "${var.project_name}-health-check-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period             = "60"
  statistic          = "Minimum"
  threshold          = "1"
  alarm_description  = "This metric monitors the health check status"
  
  dimensions = {
    HealthCheckId = aws_route53_health_check.main.id
  }
  
  alarm_actions = [var.sns_topic_arn]
}

# Create CloudWatch Alarm for Query Volume
resource "aws_cloudwatch_metric_alarm" "query_volume_alarm" {
  alarm_name          = "${var.project_name}-query-volume-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DNSQueries"
  namespace           = "AWS/Route53"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.query_threshold
  alarm_description  = "This metric monitors the DNS query volume"
  
  dimensions = {
    HostedZoneId = aws_route53_zone.main.zone_id
  }
  
  alarm_actions = [var.sns_topic_arn]
}

# Create S3 Website Alias Record
resource "aws_route53_record" "s3_website" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "static.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = var.s3_website_domain
    zone_id               = var.s3_website_zone_id
    evaluate_target_health = false
  }
}

# Create CloudFront Distribution Alias Record
resource "aws_route53_record" "cdn" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "cdn.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = var.cloudfront_domain_name
    zone_id               = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# Create API Gateway Alias Record
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = var.api_gateway_domain_name
    zone_id               = var.api_gateway_zone_id
    evaluate_target_health = true
  }
} 