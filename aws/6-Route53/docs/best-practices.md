# Amazon Route53 Best Practices

## DNS Management

### Naming Conventions
```hcl
# Use consistent naming patterns
resource "aws_route53_zone" "main" {
  name = "example.com"
  
  tags = {
    Environment = "Production"
    Project     = "Main Website"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.example.com"
  type    = "A"
  
  alias {
    name                   = aws_lb.main.dns_name
    zone_id               = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
```

### TTL Settings
- Use shorter TTLs for frequently changing records
- Use longer TTLs for stable records
```hcl
# Stable record with longer TTL
resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "example.com"
  type    = "MX"
  ttl     = "3600"  # 1 hour
  records = ["10 mail.example.com"]
}

# Dynamic record with shorter TTL
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.example.com"
  type    = "A"
  ttl     = "60"  # 1 minute
  records = ["192.0.2.1"]
}
```

## High Availability

### Health Checks
```hcl
# Comprehensive health check configuration
resource "aws_route53_health_check" "web" {
  fqdn              = "example.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"
  
  tags = {
    Name = "web-health-check"
  }
  
  regions = ["us-west-1", "us-east-1", "eu-west-1"]
  
  search_string = "OK"
  
  alarm_identifier {
    name   = "WebServerCPUUtilization"
    region = "us-west-2"
  }
}
```

### Failover Configuration
```hcl
# Primary record with health check
resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.example.com"
  type    = "A"
  
  failover_routing_policy {
    type = "PRIMARY"
  }
  
  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.primary.id
  
  alias {
    name                   = aws_lb.primary.dns_name
    zone_id               = aws_lb.primary.zone_id
    evaluate_target_health = true
  }
}

# Secondary record for failover
resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.example.com"
  type    = "A"
  
  failover_routing_policy {
    type = "SECONDARY"
  }
  
  set_identifier = "secondary"
  
  alias {
    name                   = aws_lb.secondary.dns_name
    zone_id               = aws_lb.secondary.zone_id
    evaluate_target_health = true
  }
}
```

## Security

### DNSSEC Implementation
```hcl
# KMS key for DNSSEC
resource "aws_kms_key" "dnssec" {
  description              = "KMS key for DNSSEC"
  customer_master_key_spec = "ECC_NIST_P256"
  key_usage               = "SIGN_VERIFY"
  deletion_window_in_days = 7
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Route 53 DNSSEC Service"
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign"
        ]
        Resource = "*"
      }
    ]
  })
}

# Key signing key
resource "aws_route53_key_signing_key" "main" {
  hosted_zone_id             = aws_route53_zone.main.id
  key_management_service_arn = aws_kms_key.dnssec.arn
  name                      = "example"
}

# Enable DNSSEC
resource "aws_route53_hosted_zone_dnssec" "main" {
  hosted_zone_id = aws_route53_zone.main.id
}
```

### Query Logging
```hcl
# CloudWatch log group for DNS queries
resource "aws_cloudwatch_log_group" "dns_queries" {
  name              = "/aws/route53/${aws_route53_zone.main.name}"
  retention_in_days = 30
  
  tags = {
    Name = "DNS Query Logs"
  }
}

# Log resource policy
resource "aws_cloudwatch_log_resource_policy" "route53" {
  policy_name = "route53-query-logging"
  
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
        Resource = "${aws_cloudwatch_log_group.dns_queries.arn}:*"
      }
    ]
  })
}

# Enable query logging
resource "aws_route53_query_log" "main" {
  depends_on = [aws_cloudwatch_log_resource_policy.route53]
  
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.dns_queries.arn
  zone_id                  = aws_route53_zone.main.id
}
```

## Cost Optimization

### Health Check Configuration
```hcl
# Cost-effective health check
resource "aws_route53_health_check" "basic" {
  fqdn              = "example.com"
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"  # Use 30 seconds instead of 10 for cost savings
  
  regions = ["us-west-2"]  # Use single region for basic monitoring
  
  tags = {
    Name = "basic-health-check"
  }
}
```

### Traffic Management
```hcl
# Cost-effective routing using weighted policy
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.example.com"
  type    = "A"
  
  weighted_routing_policy {
    weight = 90
  }
  
  set_identifier = "primary"
  records        = [aws_instance.primary.private_ip]
}

resource "aws_route53_record" "api_secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.example.com"
  type    = "A"
  
  weighted_routing_policy {
    weight = 10
  }
  
  set_identifier = "secondary"
  records        = [aws_instance.secondary.private_ip]
}
```

## Monitoring and Alerting

### CloudWatch Alarms
```hcl
# Health check status alarm
resource "aws_cloudwatch_metric_alarm" "health_check" {
  alarm_name          = "route53-health-check-failed"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period             = "60"
  statistic          = "Minimum"
  threshold          = "1"
  alarm_description  = "Route53 health check status has failed"
  
  dimensions = {
    HealthCheckId = aws_route53_health_check.web.id
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# Query volume alarm
resource "aws_cloudwatch_metric_alarm" "query_volume" {
  alarm_name          = "route53-high-query-volume"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DNSQueries"
  namespace           = "AWS/Route53"
  period             = "300"
  statistic          = "Sum"
  threshold          = "10000"
  alarm_description  = "High DNS query volume detected"
  
  dimensions = {
    HostedZoneId = aws_route53_zone.main.zone_id
  }
  
  alarm_actions = [aws_sns_topic.alerts.arn]
}
```

## Integration with Other AWS Services

### ACM Certificate Validation
```hcl
# ACM certificate validation using Route53
resource "aws_acm_certificate" "main" {
  domain_name       = "example.com"
  validation_method = "DNS"
  
  subject_alternative_names = ["*.example.com"]
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  
  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
```

### Private API Gateway
```hcl
# Private API Gateway with Route53 alias
resource "aws_api_gateway_domain_name" "main" {
  domain_name              = "api.example.com"
  regional_certificate_arn = aws_acm_certificate.main.arn
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.example.com"
  type    = "A"
  
  alias {
    name                   = aws_api_gateway_domain_name.main.regional_domain_name
    zone_id               = aws_api_gateway_domain_name.main.regional_zone_id
    evaluate_target_health = true
  }
}
``` 