output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.multi_origin.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.multi_origin.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "Route53 zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.multi_origin.hosted_zone_id
}

output "custom_domain_name" {
  description = "Custom domain name for the CloudFront distribution"
  value       = "cdn.${var.domain_name}"
}

output "static_bucket_details" {
  description = "Details of the static content S3 bucket"
  value = {
    name       = aws_s3_bucket.static_content.id
    arn        = aws_s3_bucket.static_content.arn
    domain_name = aws_s3_bucket.static_content.bucket_regional_domain_name
  }
}

output "backup_bucket_details" {
  description = "Details of the backup content S3 bucket"
  value = {
    name       = aws_s3_bucket.backup_content.id
    arn        = aws_s3_bucket.backup_content.arn
    domain_name = aws_s3_bucket.backup_content.bucket_regional_domain_name
  }
}

output "origin_access_identity" {
  description = "CloudFront origin access identity details"
  value = {
    id        = aws_cloudfront_origin_access_identity.static_content.id
    iam_arn   = aws_cloudfront_origin_access_identity.static_content.iam_arn
    path      = aws_cloudfront_origin_access_identity.static_content.cloudfront_access_identity_path
  }
}

output "field_level_encryption_config" {
  description = "Field-level encryption configuration details"
  value = {
    config_id  = aws_cloudfront_field_level_encryption_config.example.id
    profile_id = aws_cloudfront_field_level_encryption_profile.example.id
    public_key = aws_cloudfront_public_key.example.id
  }
}

output "cache_behaviors" {
  description = "Cache behavior paths configured"
  value = {
    static_content = "/static/*"
    api            = "/api/*"
  }
}

output "origin_groups" {
  description = "Origin group details"
  value = {
    s3_failover = {
      id            = "OriginGroupS3"
      primary       = "S3Origin"
      secondary     = "S3OriginBackup"
      status_codes  = [500, 502, 503, 504]
    }
  }
}

output "custom_error_responses" {
  description = "Custom error response configurations"
  value = {
    "404" = {
      response_code = 200
      response_path = "/errors/404.html"
      cache_ttl    = 300
    }
    "500" = {
      response_code = 500
      response_path = "/errors/500.html"
      cache_ttl    = 60
    }
  }
}

output "geographic_restrictions" {
  description = "Geographic restriction details"
  value = {
    type      = "whitelist"
    countries = var.allowed_countries
  }
}

output "cloudwatch_alarms" {
  description = "CloudWatch alarm ARNs"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.origin_errors : k => v.arn
  }
}

output "route53_record" {
  description = "Route53 record details"
  value = {
    name  = aws_route53_record.cdn.name
    type  = aws_route53_record.cdn.type
    fqdn  = aws_route53_record.cdn.fqdn
  }
} 