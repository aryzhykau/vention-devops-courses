# Task 2: Advanced CloudFront Features

This task guides you through implementing advanced CloudFront features including multiple origins, path-based routing, origin groups, and custom error pages.

## Prerequisites

- Completed Task 1: Basic CloudFront Setup
- Application Load Balancer set up with a sample application
- S3 bucket with static content
- SSL certificate in ACM

## Task Objectives

1. Configure multiple origins (S3 and ALB)
2. Implement path-based routing
3. Set up origin groups for failover
4. Configure advanced cache behaviors
5. Set up compression and custom error pages
6. Implement field-level encryption
7. Configure georestrictions

## Implementation Steps

### 1. Configure Multiple Origins
```hcl
# S3 Origin
origin {
  domain_name = aws_s3_bucket.static_content.bucket_regional_domain_name
  origin_id   = "S3Origin"
  
  s3_origin_config {
    origin_access_identity = aws_cloudfront_origin_access_identity.static_content.cloudfront_access_identity_path
  }
}

# ALB Origin
origin {
  domain_name = aws_lb.application.dns_name
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
```

### 2. Path-Based Routing
```hcl
# Static content behavior
ordered_cache_behavior {
  path_pattern     = "/static/*"
  target_origin_id = "S3Origin"
  
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

# Dynamic content behavior
ordered_cache_behavior {
  path_pattern     = "/api/*"
  target_origin_id = "ALBOrigin"
  
  allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  cached_methods   = ["GET", "HEAD"]
  
  forwarded_values {
    query_string = true
    cookies {
      forward = "all"
    }
    headers = ["Host", "Authorization"]
  }
  
  viewer_protocol_policy = "https-only"
  min_ttl                = 0
  default_ttl            = 0
  max_ttl                = 0
}
```

### 3. Origin Groups for Failover
```hcl
# Origin group configuration
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
```

### 4. Custom Error Pages
```hcl
# Custom error response
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
```

### 5. Field-Level Encryption
```hcl
# Field-level encryption configuration
field_level_encryption_config {
  content_type_profile_config {
    forward_when_content_type_is_unknown = false
    content_type_profiles {
      items {
        content_type = "application/x-www-form-urlencoded"
        format       = "URLEncoded"
      }
    }
  }
  
  query_arg_profile_config {
    forward_when_query_arg_profile_is_unknown = false
  }
}
```

### 6. Geographic Restrictions
```hcl
# Geo restriction configuration
restrictions {
  geo_restriction {
    restriction_type = "whitelist"
    locations        = ["US", "CA", "GB", "DE"]
  }
}
```

## Validation Steps

1. Test path-based routing:
```bash
# Test static content
curl -v https://cdn.example.com/static/image.jpg

# Test dynamic content
curl -v https://cdn.example.com/api/data
```

2. Test failover:
```bash
# Monitor origin health
aws cloudfront get-distribution --id <distribution-id>

# Test failover by stopping primary origin
curl -v https://cdn.example.com/static/test.html
```

3. Test custom error pages:
```bash
# Test 404 error
curl -v https://cdn.example.com/nonexistent

# Test 500 error
curl -v https://cdn.example.com/api/error-trigger
```

4. Test geographic restrictions:
```bash
# Test from allowed location (using VPN)
curl -v https://cdn.example.com/

# Test from restricted location (using VPN)
curl -v https://cdn.example.com/
```

5. Test field-level encryption:
```bash
# Submit form with sensitive data
curl -X POST -d "creditcard=1234-5678-9012-3456" https://cdn.example.com/api/payment
```

## Common Issues and Solutions

1. Origin Connection Issues
- Problem: CloudFront can't connect to ALB
- Solution: Check security groups and origin custom headers

2. Cache Behavior Conflicts
- Problem: Wrong origin serving content
- Solution: Check path pattern order and specificity

3. Failover Not Working
- Problem: No failover to backup origin
- Solution: Verify origin group configuration and health check settings

4. Field-Level Encryption Issues
- Problem: Encrypted fields not working
- Solution: Check content type configuration and public key setup

## Additional Resources

- [Working with Multiple Origins](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-working-with.html)
- [Cache Behavior Settings](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html)
- [Origin Groups](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/high_availability_origin_failover.html)
- [Field-Level Encryption](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/field-level-encryption.html) 