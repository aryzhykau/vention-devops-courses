output "zone_id" {
  description = "The Hosted Zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "A list of name servers in associated (or default) delegation set"
  value       = aws_route53_zone.main.name_servers
}

output "main_health_check_id" {
  description = "The ID of the main health check"
  value       = aws_route53_health_check.main.id
}

output "api_health_check_id" {
  description = "The ID of the API health check"
  value       = aws_route53_health_check.api.id
}

output "dns_query_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for DNS queries"
  value       = aws_cloudwatch_log_group.dns_query_logs.arn
}

output "health_check_alarm_arn" {
  description = "The ARN of the health check CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.health_check_alarm.arn
}

output "query_volume_alarm_arn" {
  description = "The ARN of the query volume CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.query_volume_alarm.arn
}

output "domain_records" {
  description = "Map of created DNS records"
  value = {
    main_a      = aws_route53_record.main_a.fqdn
    main_aaaa   = aws_route53_record.main_aaaa.fqdn
    www         = aws_route53_record.www.fqdn
    mx          = aws_route53_record.mx.fqdn
    txt         = aws_route53_record.txt.fqdn
    s3_website  = aws_route53_record.s3_website.fqdn
    cdn         = aws_route53_record.cdn.fqdn
    api         = aws_route53_record.api.fqdn
  }
} 