# CloudTrail Troubleshooting Guide

This guide provides solutions for common issues encountered with AWS CloudTrail and its components.

## Common Issues and Solutions

### 1. Trail Not Logging Events

#### Problem: Events not appearing in CloudTrail
```
No events found in CloudTrail logs
```

**Solutions:**
1. Check Trail Status:
```bash
aws cloudtrail get-trail-status \
  --name trail-name
```

2. Verify Trail Configuration:
```hcl
resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name               = aws_s3_bucket.trail.id
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
```

3. Check S3 Bucket Permissions:
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
      }
    ]
  })
}
```

### 2. Log Delivery Issues

#### Problem: Logs not delivered to S3
```
CloudTrail logs not appearing in S3 bucket
```

**Solutions:**
1. Check S3 Bucket Configuration:
```hcl
resource "aws_s3_bucket" "trail" {
  bucket        = "cloudtrail-logs"
  force_destroy = false
  
  versioning {
    enabled = true
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
```

2. Verify KMS Key Permissions:
```hcl
resource "aws_kms_key" "cloudtrail" {
  description             = "KMS key for CloudTrail logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable CloudTrail Encrypt"
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

3. Check CloudWatch Logs Integration:
```hcl
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/logs"
  retention_in_days = 30
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "cloudtrail-cloudwatch"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
```

### 3. Event Selector Issues

#### Problem: Specific events not being logged
```
Expected events missing from CloudTrail logs
```

**Solutions:**
1. Check Event Selector Configuration:
```hcl
resource "aws_cloudtrail" "data_events" {
  name                          = "data-events-trail"
  s3_bucket_name               = aws_s3_bucket.trail.id
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::my-bucket/"]
    }
  }
}
```

2. Verify Service Support:
```bash
aws cloudtrail list-public-keys
```

3. Check Resource ARNs:
```bash
aws cloudtrail get-event-selectors \
  --trail-name trail-name
```

### 4. Organization Trail Issues

#### Problem: Member account events not logged
```
Organization trail not capturing member account events
```

**Solutions:**
1. Check Organization Trail Configuration:
```hcl
resource "aws_cloudtrail" "organization" {
  name                          = "organization-trail"
  s3_bucket_name               = aws_s3_bucket.organization_trail.id
  is_organization_trail        = true
  enable_logging               = true
  
  organization_config {
    enable_data_events = true
  }
}
```

2. Verify Organization Access:
```hcl
resource "aws_organizations_organization" "main" {
  feature_set = "ALL"
  
  aws_service_access_principals = ["cloudtrail.amazonaws.com"]
}
```

3. Check Member Account Status:
```bash
aws organizations list-accounts \
  --query 'Accounts[*].[Id,Status]'
```

## Diagnostic Tools

### 1. CloudWatch Logs Insights
```sql
fields @timestamp, eventName, errorCode, errorMessage
| filter errorCode != null
| sort @timestamp desc
| limit 20
```

### 2. CloudTrail Lake Queries
```sql
SELECT eventName, userIdentity.userName, errorCode
FROM trail_selector
WHERE errorCode IS NOT NULL
AND eventTime >= ago(24h)
```

### 3. CloudWatch Metrics
```hcl
resource "aws_cloudwatch_metric_alarm" "trail_errors" {
  alarm_name          = "cloudtrail-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "ErrorCount"
  namespace          = "AWS/CloudTrail"
  period            = "300"
  statistic         = "Sum"
  threshold         = "0"
  
  dimensions = {
    TrailName = aws_cloudtrail.main.name
  }
}
```

## Best Practices

### 1. Monitoring Setup
- Enable CloudWatch integration
- Configure metric filters
- Set up alerts
- Monitor delivery status

### 2. Log Management
- Configure proper retention
- Implement lifecycle policies
- Monitor storage usage
- Enable log validation

### 3. Security Configuration
- Enable encryption
- Configure access policies
- Monitor security events
- Implement alerts

### 4. Performance Optimization
- Use selective logging
- Configure proper buffers
- Monitor API limits
- Optimize queries

## Additional Resources

- [CloudTrail Troubleshooting Guide](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-troubleshooting.html)
- [CloudTrail Lake Queries](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/query-lake.html)
- [CloudWatch Logs Integration](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/send-cloudtrail-events-to-cloudwatch-logs.html)
- [Organization Trails](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html) 