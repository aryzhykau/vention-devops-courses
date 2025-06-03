# CloudTrail Best Practices

This document outlines best practices for implementing AWS CloudTrail in production environments.

## Trail Configuration Best Practices

### 1. Trail Setup
```hcl
resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name               = aws_s3_bucket.trail.id
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true
  
  enable_log_file_validation    = true
  kms_key_id                   = aws_kms_key.cloudtrail.arn
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }
  
  tags = {
    Environment = "Production"
    Service     = "Audit"
  }
}
```

### 2. S3 Bucket Configuration
```hcl
resource "aws_s3_bucket" "trail" {
  bucket        = "cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = false
  
  versioning {
    enabled = true
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_key_id = aws_kms_key.cloudtrail.arn
        sse_algorithm = "aws:kms"
      }
    }
  }
  
  lifecycle_rule {
    enabled = true
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    
    expiration {
      days = 365
    }
  }
}
```

## Security Best Practices

### 1. KMS Encryption
```hcl
resource "aws_kms_key" "cloudtrail" {
  description             = "KMS key for CloudTrail logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudTrail to encrypt logs"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### 2. Bucket Policy
```hcl
resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.trail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.trail.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
```

## Monitoring Best Practices

### 1. CloudWatch Integration
```hcl
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/audit-logs"
  retention_in_days = 30
  
  tags = {
    Environment = "Production"
    Service     = "Audit"
  }
}

resource "aws_cloudtrail" "main" {
  # ... other configuration ...
  
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch.arn
}
```

### 2. Metric Filters
```hcl
resource "aws_cloudwatch_metric_filter" "root_login" {
  name           = "root-account-usage"
  pattern        = "{ $.userIdentity.type = Root }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name      = "RootAccountUsage"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}
```

## Organization Trail Best Practices

### 1. Organization Trail Setup
```hcl
resource "aws_cloudtrail" "organization" {
  name                          = "organization-trail"
  s3_bucket_name               = aws_s3_bucket.organization_trail.id
  include_global_service_events = true
  is_multi_region_trail        = true
  is_organization_trail        = true
  enable_logging               = true
  
  enable_log_file_validation    = true
  kms_key_id                   = aws_kms_key.organization_trail.arn
}
```

### 2. Cross-Account Access
```hcl
resource "aws_iam_role" "cloudtrail_access" {
  name = "cloudtrail-cross-account-access"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.security_account_id}:root"
        }
      }
    ]
  })
}
```

## Cost Optimization

### 1. Event Selection
- Configure appropriate event selectors
- Filter unnecessary events
- Use sampling for high-volume events
- Implement proper retention policies

### 2. Storage Management
- Configure lifecycle policies
- Use appropriate storage classes
- Monitor storage usage
- Clean up old logs

## Compliance Requirements

### 1. Log Retention
- Determine retention requirements
- Implement appropriate policies
- Monitor compliance
- Document procedures

### 2. Access Controls
- Implement least privilege
- Regular access reviews
- Monitor policy changes
- Document access patterns

## Additional Considerations

### 1. Performance
- Monitor delivery latency
- Optimize log processing
- Configure appropriate buffers
- Monitor API throttling

### 2. Disaster Recovery
- Cross-region replication
- Backup configuration
- Recovery procedures
- Testing strategy

## Best Practices Checklist

1. Trail Configuration
   - [ ] Enable multi-region logging
   - [ ] Configure global service events
   - [ ] Enable log file validation
   - [ ] Set up appropriate event selectors

2. Security
   - [ ] Enable KMS encryption
   - [ ] Configure bucket policies
   - [ ] Enable MFA delete
   - [ ] Implement access controls

3. Monitoring
   - [ ] Set up CloudWatch integration
   - [ ] Configure metric filters
   - [ ] Create alerts
   - [ ] Monitor delivery

4. Cost Management
   - [ ] Configure retention policies
   - [ ] Implement lifecycle rules
   - [ ] Monitor usage
   - [ ] Optimize event selection

## Additional Resources

- [CloudTrail Security Documentation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/best-practices-security.html)
- [CloudTrail Organization Documentation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html)
- [CloudTrail Monitoring Documentation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/monitor-cloudtrail-log-files.html)
- [CloudTrail Cost Documentation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-pricing.html) 