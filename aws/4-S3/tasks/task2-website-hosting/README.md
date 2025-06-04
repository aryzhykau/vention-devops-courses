# Task 2: Static Website Hosting

This task demonstrates setting up a static website using S3 and CloudFront with HTTPS support.

## Objectives
1. Configure S3 bucket for static website hosting
2. Set up CloudFront distribution
3. Configure custom domain with Route 53
4. Implement SSL/TLS using ACM
5. Set up proper security headers

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured
- Registered domain name (for custom domain setup)
- Basic understanding of DNS

## Implementation Steps

### 1. S3 Configuration
- Create website bucket
- Enable static website hosting
- Configure index/error documents
- Set proper CORS rules

### 2. CloudFront Setup
```hcl
# Example CloudFront configuration
resource "aws_cloudfront_distribution" "website" {
  enabled = true
  
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website.id}"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }
  
  default_cache_behavior {
    target_origin_id = "S3-${aws_s3_bucket.website.id}"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    
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
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
```

### 3. SSL/TLS Configuration
- Request ACM certificate
- Validate domain ownership
- Associate with CloudFront
- Configure security policy

### 4. DNS Configuration
- Create Route 53 hosted zone
- Configure DNS records
- Set up domain aliases
- Implement health checks

### 5. Security Headers
- Configure security headers
- Implement CORS policy
- Set up bucket policy
- Enable logging

## Architecture Diagram
```
                    CloudFront
                        |
                    Route 53
                        |
                    ACM Cert
                        |
                    S3 Bucket
                    /        \
               Website     Logs
              Content
```

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the execution plan:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. Upload website content:
```bash
aws s3 sync ./website/ s3://your-bucket-name/
```

## Validation Steps

1. Check Website Configuration:
```bash
aws s3api get-bucket-website --bucket your-bucket-name
```

2. Verify CloudFront:
```bash
aws cloudfront list-distributions
```

3. Test SSL Configuration:
```bash
curl -I https://your-domain.com
```

4. Validate Security Headers:
```bash
curl -I https://your-domain.com | grep -i "security"
```

## Cleanup

To remove all resources:
```bash
# Remove all objects from bucket first
aws s3 rm s3://your-bucket-name --recursive

# Destroy infrastructure
terraform destroy
```

## Additional Notes
- Wait for ACM certificate validation
- CloudFront distribution takes time to deploy
- DNS propagation may take 24-48 hours
- Keep website content organized
- Monitor CloudFront costs

## Troubleshooting

### Common Issues
1. Certificate validation
   - Check DNS records
   - Verify domain ownership
   - Wait for propagation

2. CloudFront issues
   - Check origin configuration
   - Verify cache settings
   - Review error logs

3. DNS problems
   - Verify record sets
   - Check nameservers
   - Wait for propagation

### Logs Location
- S3 access logs
- CloudFront logs
- Route 53 query logs
- CloudWatch metrics

### Useful Commands
```bash
# Check certificate status
aws acm describe-certificate --certificate-arn your-cert-arn

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id your-dist-id --paths "/*"

# Test website endpoint
curl -I http://your-bucket-name.s3-website-region.amazonaws.com
```

### Security Best Practices
1. Always use HTTPS
2. Implement proper CORS
3. Set security headers
4. Enable logging
5. Regular security reviews 