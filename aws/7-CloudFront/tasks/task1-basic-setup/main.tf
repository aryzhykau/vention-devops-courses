# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Provider for ACM Certificate (must be in us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Create S3 bucket for static content
resource "aws_s3_bucket" "static_content" {
  bucket = var.bucket_name
  
  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "static_content" {
  bucket = aws_s3_bucket.static_content.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure bucket for website hosting
resource "aws_s3_bucket_website_configuration" "static_content" {
  bucket = aws_s3_bucket.static_content.id
  
  index_document {
    suffix = "index.html"
  }
  
  error_document {
    key = "error.html"
  }
}

# Create S3 bucket for CloudFront logs
resource "aws_s3_bucket" "logs" {
  bucket = var.logs_bucket_name
  
  tags = {
    Name        = var.logs_bucket_name
    Environment = var.environment
  }
}

# Create Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "static_content" {
  comment = "OAI for ${var.domain_name}"
}

# Create bucket policy
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

# Attach bucket policy
resource "aws_s3_bucket_policy" "static_content" {
  bucket = aws_s3_bucket.static_content.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

# Create ACM Certificate
resource "aws_acm_certificate" "cdn" {
  provider                  = aws.us_east_1
  domain_name              = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method        = "DNS"
  
  tags = {
    Environment = var.environment
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Create Route53 records for ACM validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cdn.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "cdn" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cdn.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Create CloudFront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_content.bucket_regional_domain_name
    origin_id   = "S3Origin"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_content.cloudfront_access_identity_path
    }
  }
  
  enabled             = true
  is_ipv6_enabled    = true
  comment             = "Distribution for ${var.domain_name}"
  default_root_object = "index.html"
  
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cloudfront/"
  }
  
  aliases = ["cdn.${var.domain_name}"]
  
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"
    
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
  }
  
  price_class = var.price_class
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cdn.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  
  tags = {
    Environment = var.environment
  }
  
  depends_on = [aws_acm_certificate_validation.cdn]
}

# Create Route53 record for CloudFront
resource "aws_route53_record" "cdn" {
  zone_id = var.route53_zone_id
  name    = "cdn.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# Create CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "error_rate" {
  alarm_name          = "${var.environment}-cloudfront-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period             = "300"
  statistic          = "Average"
  threshold          = "5"
  alarm_description  = "This metric monitors CloudFront error rate"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    DistributionId = aws_cloudfront_distribution.s3_distribution.id
    Region         = "Global"
  }
}

resource "aws_cloudwatch_metric_alarm" "cache_hit_rate" {
  alarm_name          = "${var.environment}-cloudfront-cache-hit-rate"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CacheHitRate"
  namespace           = "AWS/CloudFront"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors CloudFront cache hit rate"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    DistributionId = aws_cloudfront_distribution.s3_distribution.id
    Region         = "Global"
  }
} 