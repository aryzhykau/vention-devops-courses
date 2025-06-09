output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].id : null
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].arn : null
}

output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_domain_validation_options" {
  description = "Domain validation options for the certificate"
  value       = aws_acm_certificate.main.domain_validation_options
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "secrets_manager_secrets" {
  description = "Map of created secrets in Secrets Manager"
  value = var.enable_secrets_manager ? {
    for secret in aws_secretsmanager_secret.secrets : secret.name => {
      arn         = secret.arn
      description = secret.description
    }
  } : null
}

output "cloudwatch_alarms" {
  description = "List of CloudWatch alarms"
  value = var.enable_monitoring ? {
    waf_blocked_requests = var.enable_waf ? aws_cloudwatch_metric_alarm.waf_blocked_requests[0].arn : null
  } : null
}

output "sns_topic" {
  description = "ARN of the SNS topic for security alerts"
  value       = var.enable_monitoring && var.alert_email != "" ? aws_sns_topic.security_alerts[0].arn : null
}

output "lambda_function" {
  description = "Details of the security headers Lambda function"
  value = var.security_headers.hsts || var.security_headers.content_security_policy ? {
    function_name = aws_lambda_function.security_headers[0].function_name
    function_arn  = aws_lambda_function.security_headers[0].arn
    role_arn     = aws_iam_role.lambda_security_headers[0].arn
  } : null
}

output "security_headers_enabled" {
  description = "Map of enabled security headers"
  value       = var.security_headers
} 