# Amazon CloudFront Training Module

This module provides hands-on training for Amazon CloudFront, AWS's content delivery network (CDN) service.

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Terraform installed (v1.0.0+)
- Completed S3 and Route53 modules
- Basic understanding of CDN concepts

## Learning Objectives

After completing this module, you will be able to:

1. Understand CloudFront core concepts:
   - Distributions
   - Origins (S3, ALB, Custom)
   - Cache Behaviors
   - Edge Locations
   - Regional Edge Caches
   - SSL/TLS Certificates
   - Security Features

2. Implement CloudFront configurations:
   - Create and manage distributions
   - Configure origins and behaviors
   - Set up caching strategies
   - Implement security features
   - Integrate with other AWS services

3. Follow AWS best practices for:
   - Performance optimization
   - Cost optimization
   - Security
   - High availability
   - Monitoring and logging

## Module Structure

```
08-CloudFront/
├── docs/
│   ├── concepts.md
│   └── best-practices.md
└── tasks/
    ├── task1-basic-setup/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── task2-advanced-features/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
    
```

## Tasks Overview

### Task 1: Basic CloudFront Setup
- Create a CloudFront distribution
- Configure S3 origin
- Set up basic cache behavior
- Configure SSL/TLS certificate
- Set up custom domain with Route53
- Implement basic logging

### Task 2: Advanced CloudFront Features
- Configure multiple origins (S3, ALB)
- Set up path-based routing
- Implement origin groups for failover
- Configure cache behaviors
- Set up compression
- Implement custom error pages
- Configure georestrictions
- Set up field-level encryption

## Validation

Each task includes validation steps to ensure proper implementation:

1. Distribution validation:
```bash
curl -v https://your-distribution.cloudfront.net
```

2. Cache behavior testing:
```bash
# Test cache hit/miss
curl -I https://your-distribution.cloudfront.net/path
```

3. Security validation:
```bash
# Test signed URLs
curl -v "https://your-distribution.cloudfront.net/private/file?[signed-url-parameters]"
```

## Common Issues and Troubleshooting

1. Cache Issues
- Issue: Content not updating
- Solution: Invalidate cache or adjust TTL

2. SSL/TLS Problems
- Issue: Certificate validation
- Solution: Verify ACM certificate status and region

3. Origin Access
- Issue: Access denied errors
- Solution: Check OAI configuration and bucket policy

4. Performance
- Issue: Slow content delivery
- Solution: Review cache settings and origin health

## Additional Resources

- [CloudFront Developer Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html)
- [CloudFront API Reference](https://docs.aws.amazon.com/cloudfront/latest/APIReference/Welcome.html)
- [AWS CDN Best Practices](https://aws.amazon.com/blogs/networking-and-content-delivery/category/networking-content-delivery/amazon-cloudfront/)
- [CloudFront Security](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/security.html)
- [CloudFront Pricing](https://aws.amazon.com/cloudfront/pricing/) 