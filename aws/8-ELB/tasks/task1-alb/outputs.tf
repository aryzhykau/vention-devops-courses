output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.app.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.app.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "Route53 zone ID of the Application Load Balancer"
  value       = aws_lb.app.zone_id
}

output "target_groups" {
  description = "Map of target groups created and their attributes"
  value = {
    api = {
      arn  = aws_lb_target_group.api.arn
      name = aws_lb_target_group.api.name
      id   = aws_lb_target_group.api.id
    }
    static = {
      arn  = aws_lb_target_group.static.arn
      name = aws_lb_target_group.static.name
      id   = aws_lb_target_group.static.id
    }
  }
}

output "security_groups" {
  description = "Map of security groups created and their IDs"
  value = {
    alb     = aws_security_group.alb.id
    targets = aws_security_group.targets.id
  }
}

output "listeners" {
  description = "Map of listeners created and their ARNs"
  value = {
    http  = aws_lb_listener.http.arn
    https = aws_lb_listener.https.arn
  }
}

output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarms created"
  value = {
    unhealthy_hosts = {
      for k, v in aws_cloudwatch_metric_alarm.unhealthy_hosts : k => v.arn
    }
    high_5xx    = aws_cloudwatch_metric_alarm.high_5xx.arn
    high_4xx    = aws_cloudwatch_metric_alarm.high_4xx.arn
    high_latency = aws_cloudwatch_metric_alarm.high_latency.arn
  }
}

output "s3_logs_bucket" {
  description = "Details of the S3 bucket created for ALB access logs"
  value = {
    id     = aws_s3_bucket.logs.id
    arn    = aws_s3_bucket.logs.arn
    domain = aws_s3_bucket.logs.bucket_domain_name
  }
}

output "route53_record" {
  description = "Details of the Route53 record created for the ALB"
  value = var.create_dns_record ? {
    name    = aws_route53_record.alb[0].name
    zone_id = aws_route53_record.alb[0].zone_id
    fqdn    = aws_route53_record.alb[0].fqdn
  } : null
} 