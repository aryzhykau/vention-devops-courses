# Task 1: Basic CloudFront Setup

This task guides you through setting up a basic CloudFront distribution with an S3 origin.

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Terraform installed (v1.0.0+)
- Domain name registered in Route53 (optional for custom domain)
- SSL certificate in ACM (for custom domain)

## Task Objectives

1. Create an S3 bucket for static content
2. Set up a CloudFront distribution
3. Configure basic cache behavior
4. Implement SSL/TLS with ACM
5. Set up custom domain with Route53
6. Configure basic logging

## Implementation Steps

### 1. Create S3 Bucket
```hcl
# Create S3 bucket for static content
resource "aws_s3_bucket" "static_content" {
  bucket = "my-static-content-bucket"
}

# Configure bucket for website hosting
resource "aws_s3_bucket_website_configuration" {
  bucket = aws_s3_bucket.static_content.id
  
  index_document {
    suffix = "index.html"
  }
  
  error_document {
    key = "error.html"
  }
}
```

### 2. Create CloudFront Distribution
```hcl
# Create CloudFront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_content.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }
  
  enabled             = true
  is_ipv6_enabled    = true
  default_root_object = "index.html"
  
  # ... additional configuration ...
}
```

### 3. Configure Cache Behavior
```hcl
# Default cache behavior
default_cache_behavior {
  allowed_methods  = ["GET", "HEAD"]
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
}
```

### 4. SSL/TLS Configuration
```hcl
# SSL certificate configuration
viewer_certificate {
  acm_certificate_arn      = var.acm_certificate_arn
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2021"
}
```

### 5. Custom Domain Setup
```hcl
# Route53 record for custom domain
resource "aws_route53_record" "cdn" {
  zone_id = var.route53_zone_id
  name    = "cdn.example.com"
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id               = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
```

### 6. Logging Configuration
```hcl
# Logging configuration
logging_config {
  include_cookies = false
  bucket         = "my-logs-bucket.s3.amazonaws.com"
  prefix         = "cloudfront/"
}
```

## Validation Steps

1. Upload test content to S3:
```bash
aws s3 cp test.html s3://my-static-content-bucket/
```

2. Verify CloudFront distribution:
```bash
# Get distribution status
aws cloudfront get-distribution --id <distribution-id>

# Test distribution
curl -v https://<distribution-domain>/test.html
```

3. Test custom domain:
```bash
# DNS resolution
dig cdn.example.com

# HTTPS access
curl -v https://cdn.example.com/test.html
```

4. Verify SSL certificate:
```bash
# Check SSL certificate
openssl s_client -connect cdn.example.com:443
```

5. Check logs:
```bash
# List log files
aws s3 ls s3://my-logs-bucket/cloudfront/

# Download and analyze logs
aws s3 cp s3://my-logs-bucket/cloudfront/latest.log .
```

## Common Issues and Solutions

1. S3 Access Issues
- Problem: CloudFront can't access S3 bucket
- Solution: Verify bucket policy and OAI configuration

2. SSL Certificate Problems
- Problem: Certificate validation fails
- Solution: Ensure certificate is in us-east-1 region and validated

3. DNS Resolution Issues
- Problem: Custom domain not resolving
- Solution: Check Route53 alias record configuration

4. Cache Issues
- Problem: Content not updating
- Solution: Create invalidation or adjust cache settings

## Additional Resources

- [CloudFront Developer Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html)
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html)
- [ACM Certificate Management](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html)
- [Route53 Alias Records](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html) 