# S3 Best Practices

## Security

### 1. Access Control
- Block public access by default
- Use bucket policies over ACLs
- Implement least privilege
- Regular access audits
- Enable versioning

### 2. Encryption
```hcl
# Example of enforcing encryption
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "secure-bucket"
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
```

### 3. Monitoring
- Enable access logging
- Configure CloudWatch alerts
- Monitor unauthorized attempts
- Track usage patterns
- Regular security assessments

## Performance

### 1. Object Naming
- Use random prefixes
- Avoid sequential naming
- Consider workload patterns
- Optimize for parallel access
- Use appropriate delimiters

### 2. Transfer Optimization
```python
# Example of multipart upload with optimal part size
def calculate_optimal_part_size(file_size):
    """Calculate optimal part size for multipart upload"""
    min_size = 5 * 1024 * 1024  # 5MB
    max_parts = 10000
    optimal_part_size = math.ceil(file_size / max_parts)
    return max(optimal_part_size, min_size)

def upload_large_file(bucket, key, file_path):
    file_size = os.path.getsize(file_path)
    part_size = calculate_optimal_part_size(file_size)
    
    s3 = boto3.client('s3')
    mpu = s3.create_multipart_upload(
        Bucket=bucket,
        Key=key,
        StorageClass='STANDARD'
    )
```

### 3. Request Rate
- Use CloudFront for caching
- Implement retry mechanisms
- Monitor throttling events
- Scale request distribution
- Use transfer acceleration

## Data Management

### 1. Lifecycle Management
```json
{
  "Rules": [
    {
      "ID": "DataLifecycle",
      "Status": "Enabled",
      "Prefix": "logs/",
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ],
      "NoncurrentVersionTransitions": [
        {
          "NoncurrentDays": 30,
          "StorageClass": "GLACIER"
        }
      ],
      "Expiration": {
        "Days": 365
      }
    }
  ]
}
```

### 2. Versioning
- Enable for critical buckets
- Configure lifecycle rules
- Monitor storage costs
- Regular cleanup
- Backup strategy

### 3. Replication
- Use for disaster recovery
- Configure proper IAM roles
- Monitor replication status
- Test failover procedures
- Regular validation

## Cost Optimization

### 1. Storage Classes
- Analyze access patterns
- Use appropriate classes
- Implement transitions
- Monitor usage costs
- Regular optimization

### 2. Lifecycle Rules
```hcl
resource "aws_s3_bucket_lifecycle_configuration" "cost_optimize" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "cost-optimization"
    status = "Enabled"

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

### 3. Monitoring and Analytics
- Use Storage Lens
- Configure cost alerts
- Track usage metrics
- Regular cost reviews
- Implement tagging

## Backup and Recovery

### 1. Backup Strategy
- Regular backups
- Cross-region replication
- Version control
- Retention policies
- Recovery testing

### 2. Disaster Recovery
```hcl
resource "aws_s3_bucket" "backup" {
  bucket = "backup-bucket"
  
  versioning {
    enabled = true
  }
  
  replication_configuration {
    role = aws_iam_role.replication.arn
    
    rules {
      id     = "backup"
      status = "Enabled"
      
      destination {
        bucket        = aws_s3_bucket.backup_destination.arn
        storage_class = "STANDARD_IA"
      }
    }
  }
}
```

### 3. Data Protection
- Object lock configuration
- MFA delete
- Backup validation
- Regular testing
- Documentation

## Compliance

### 1. Logging
- Access logging
- CloudTrail integration
- Audit trails
- Compliance reporting
- Regular reviews

### 2. Retention
```json
{
  "ObjectLockConfiguration": {
    "ObjectLockEnabled": "Enabled",
    "Rule": {
      "DefaultRetention": {
        "Mode": "COMPLIANCE",
        "Days": 2555
      }
    }
  }
}
```

### 3. Encryption
- Data at rest
- Data in transit
- Key management
- Regular rotation
- Audit controls

## Monitoring and Alerting

### 1. CloudWatch Integration
- Performance metrics
- Error monitoring
- Capacity planning
- Cost tracking
- Alert configuration

### 2. Event Notifications
```hcl
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.main.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
  }

  topic {
    topic_arn     = aws_sns_topic.topic.arn
    events        = ["s3:ObjectRemoved:*"]
    filter_suffix = ".log"
  }
}
```

### 3. Operational Excellence
- Regular reviews
- Documentation
- Automation
- Incident response
- Continuous improvement 