output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "Route53 zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
}

output "custom_domain_name" {
  description = "Custom domain name for the CloudFront distribution"
  value       = "cdn.${var.domain_name}"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static content"
  value       = aws_s3_bucket.static_content.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket hosting the static content"
  value       = aws_s3_bucket.static_content.arn
}

output "s3_website_endpoint" {
  description = "Website endpoint of the S3 bucket"
  value       = aws_s3_bucket_website_configuration.static_content.website_endpoint
}

output "logs_bucket_name" {
  description = "Name of the S3 bucket storing CloudFront logs"
  value       = aws_s3_bucket.logs.id
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.cdn.arn
}

output "cloudfront_origin_access_identity" {
  description = "CloudFront origin access identity path"
  value       = aws_cloudfront_origin_access_identity.static_content.cloudfront_access_identity_path
}

output "cloudwatch_alarm_arns" {
  description = "ARNs of the CloudWatch alarms"
  value = {
    error_rate     = aws_cloudwatch_metric_alarm.error_rate.arn
    cache_hit_rate = aws_cloudwatch_metric_alarm.cache_hit_rate.arn
  }
}

output "route53_record_name" {
  description = "Route53 record name for the CloudFront distribution"
  value       = aws_route53_record.cdn.name
}

output "route53_record_fqdn" {
  description = "FQDN of the Route53 record"
  value       = aws_route53_record.cdn.fqdn
} 