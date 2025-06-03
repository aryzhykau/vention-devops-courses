# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Create S3 bucket for static content
resource "aws_s3_bucket" "static_content" {
  bucket = var.static_bucket_name
  
  tags = {
    Name        = var.static_bucket_name
    Environment = var.environment
  }
}

# Create S3 bucket for backup content
resource "aws_s3_bucket" "backup_content" {
  bucket = var.backup_bucket_name
  
  tags = {
    Name        = var.backup_bucket_name
    Environment = var.environment
  }
}

# Create Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "static_content" {
  comment = "OAI for ${var.domain_name}"
}

# Create bucket policies
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_content.arn}/*"]
    
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.static_content.iam_arn]
    }
  }
}

data "aws_iam_policy_document" "s3_backup_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.backup_content.arn}/*"]
    
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.static_content.iam_arn]
    }
  }
}

# Attach bucket policies
resource "aws_s3_bucket_policy" "static_content" {
  bucket = aws_s3_bucket.static_content.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_policy" "backup_content" {
  bucket = aws_s3_bucket.backup_content.id
  policy = data.aws_iam_policy_document.s3_backup_policy.json
}

# Create public key for field-level encryption
resource "aws_cloudfront_public_key" "example" {
  comment     = "Example public key for field-level encryption"
  encoded_key = var.field_level_encryption_public_key
  name        = "example-public-key"
}

# Create field-level encryption profile
resource "aws_cloudfront_field_level_encryption_profile" "example" {
  comment = "Example encryption profile"
  name    = "example-encryption-profile"
  
  encryption_entities {
    items {
      public_key_id = aws_cloudfront_public_key.example.id
      provider_id   = "example-provider"
      
      field_patterns {
        items = ["creditcard", "ssn"]
      }
    }
  }
}

# Create field-level encryption config
resource "aws_cloudfront_field_level_encryption_config" "example" {
  comment = "Example encryption config"
  
  content_type_profile_config {
    forward_when_content_type_is_unknown = false
    content_type_profiles {
      items {
        content_type = "application/x-www-form-urlencoded"
        format       = "URLEncoded"
        profile_id   = aws_cloudfront_field_level_encryption_profile.example.id
      }
    }
  }
  
  query_arg_profile_config {
    forward_when_query_arg_profile_is_unknown = false
  }
}

# Create CloudFront distribution
resource "aws_cloudfront_distribution" "multi_origin" {
  enabled             = true
  is_ipv6_enabled    = true
  comment             = "Multi-origin distribution for ${var.domain_name}"
  default_root_object = "index.html"
  price_class         = var.price_class
  
  # S3 Origin
  origin {
    domain_name = aws_s3_bucket.static_content.bucket_regional_domain_name
    origin_id   = "S3Origin"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_content.cloudfront_access_identity_path
    }
  }
  
  # Backup S3 Origin
  origin {
    domain_name = aws_s3_bucket.backup_content.bucket_regional_domain_name
    origin_id   = "S3OriginBackup"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_content.cloudfront_access_identity_path
    }
  }
  
  # ALB Origin
  origin {
    domain_name = var.alb_domain_name
    origin_id   = "ALBOrigin"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    
    custom_header {
      name  = "X-Custom-Header"
      value = var.custom_header_value
    }
  }
  
  # Origin group for S3 failover
  origin_group {
    origin_id = "OriginGroupS3"
    
    failover_criteria {
      status_codes = [500, 502, 503, 504]
    }
    
    member {
      origin_id = "S3Origin"
    }
    
    member {
      origin_id = "S3OriginBackup"
    }
  }
  
  # Default cache behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "OriginGroupS3"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    
    field_level_encryption_id = aws_cloudfront_field_level_encryption_config.example.id
  }
  
  # Static content behavior
  ordered_cache_behavior {
    path_pattern     = "/static/*"
    target_origin_id = "OriginGroupS3"
    
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
  }
  
  # API behavior
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = "ALBOrigin"
    
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    
    forwarded_values {
      query_string = true
      headers      = ["Host", "Authorization"]
      
      cookies {
        forward = "all"
      }
    }
    
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    
    field_level_encryption_id = aws_cloudfront_field_level_encryption_config.example.id
  }
  
  # Custom error responses
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/errors/404.html"
    error_caching_min_ttl = 300
  }
  
  custom_error_response {
    error_code            = 500
    response_code         = 500
    response_page_path    = "/errors/500.html"
    error_caching_min_ttl = 60
  }
  
  # Geographic restrictions
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.allowed_countries
    }
  }
  
  # SSL/TLS configuration
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  
  # Web Application Firewall
  web_acl_id = var.waf_web_acl_id
  
  tags = {
    Environment = var.environment
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "origin_errors" {
  for_each = {
    s3_origin  = "S3Origin"
    alb_origin = "ALBOrigin"
  }
  
  alarm_name          = "${var.environment}-cloudfront-${each.key}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "OriginErrors"
  namespace           = "AWS/CloudFront"
  period             = "300"
  statistic          = "Sum"
  threshold          = "5"
  alarm_description  = "This metric monitors origin errors for ${each.value}"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    DistributionId = aws_cloudfront_distribution.multi_origin.id
    Region         = "Global"
  }
}

# Route53 record
resource "aws_route53_record" "cdn" {
  zone_id = var.route53_zone_id
  name    = "cdn.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.multi_origin.domain_name
    zone_id                = aws_cloudfront_distribution.multi_origin.hosted_zone_id
    evaluate_target_health = false
  }
} 