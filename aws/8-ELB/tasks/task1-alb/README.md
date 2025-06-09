# Task 1: Application Load Balancer Implementation

This task guides you through creating and configuring an Application Load Balancer (ALB) with advanced features using Terraform.

## Prerequisites

- AWS Account with appropriate permissions
- Terraform installed (v1.0.0+)
- AWS CLI configured
- Completed VPC and EC2 modules
- SSL certificate in ACM
- Sample application running on EC2 instances

## Task Objectives

1. Create an Application Load Balancer
2. Configure multiple target groups
3. Implement path-based routing
4. Set up SSL/TLS termination
5. Configure access logs and monitoring
6. Implement authentication with Cognito

## Implementation Steps

### 1. Basic ALB Setup
```hcl
# Create ALB
resource "aws_lb" "app" {
  name               = "example-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
  
  enable_deletion_protection = true
  
  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "alb-logs"
    enabled = true
  }
  
  tags = {
    Environment = var.environment
  }
}
```

### 2. Target Groups Configuration
```hcl
# API Target Group
resource "aws_lb_target_group" "api" {
  name     = "api-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# Static Content Target Group
resource "aws_lb_target_group" "static" {
  name     = "static-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    path                = "/index.html"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}
```

### 3. Listener Rules
```hcl
# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
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

# API Path Rule
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

# Static Content Rule
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
```

### 4. Security Group Configuration
```hcl
resource "aws_security_group" "alb" {
  name        = "alb-security-group"
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
}
```

### 5. Access Logging
```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "example-alb-logs"
  
  lifecycle_rule {
    enabled = true
    
    expiration {
      days = 90
    }
  }
}

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
        Resource = "${aws_s3_bucket.logs.arn}/*"
      }
    ]
  })
}
```

### 6. CloudWatch Monitoring
```hcl
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Average"
  threshold          = "0"
  alarm_description  = "Unhealthy hosts count is greater than 0"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    LoadBalancer = aws_lb.app.arn_suffix
  }
}
```

## Validation Steps

1. Test HTTPS Endpoint
```bash
# Test API endpoint
curl -v https://example.com/api/health

# Test static content
curl -v https://example.com/static/index.html
```

2. Verify SSL Configuration
```bash
# Check SSL certificate
openssl s_client -connect example.com:443 -servername example.com
```

3. Check Access Logs
```bash
# List log files
aws s3 ls s3://example-alb-logs/

# Download and view logs
aws s3 cp s3://example-alb-logs/latest.log .
```

4. Monitor CloudWatch Metrics
```bash
# Get target group health
aws elbv2 describe-target-health \
  --target-group-arn $TARGET_GROUP_ARN

# View CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancer,Value=$ALB_ARN_SUFFIX \
  --start-time $(date -d '1 hour ago' -u +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 300 \
  --statistics Sum
```

## Common Issues and Solutions

1. Health Check Failures
- Problem: Targets failing health checks
- Solution: 
  - Verify security group rules
  - Check target application health
  - Validate health check path

2. SSL Certificate Issues
- Problem: SSL handshake failures
- Solution:
  - Verify certificate domain
  - Check certificate validity
  - Confirm SSL policy

3. Access Log Issues
- Problem: Logs not appearing in S3
- Solution:
  - Check S3 bucket policy
  - Verify ALB permissions
  - Validate bucket name

4. Routing Problems
- Problem: Requests not reaching correct targets
- Solution:
  - Review listener rules
  - Check rule priorities
  - Verify target group settings

## Additional Resources

- [ALB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [ALB Access Logs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html)
- [ALB Monitoring](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-monitoring.html)
- [SSL Policies](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies) 