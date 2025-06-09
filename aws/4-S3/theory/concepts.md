# S3 Core Concepts

## Storage Classes

### S3 Standard
- Default storage class
- High availability (99.99%)
- 11 9's durability
- Replicated across 3+ AZs
- Use cases:
  - Frequently accessed data
  - Dynamic websites
  - Content distribution
  - Big data analytics

### S3 Intelligent-Tiering
- Automatic cost optimization
- Monitors access patterns
- Moves objects between tiers
- No retrieval fees
- Use cases:
  - Unknown access patterns
  - Long-lived data
  - Data lakes

### S3 Standard-IA
- Lower storage cost
- Higher retrieval cost
- 99.9% availability
- Use cases:
  - Backups
  - Disaster recovery
  - Long-term storage

### S3 Glacier
- Archival storage
- Retrieval options:
  - Expedited (1-5 minutes)
  - Standard (3-5 hours)
  - Bulk (5-12 hours)
- Use cases:
  - Long-term backups
  - Compliance archives
  - Digital preservation

## Data Management

### Bucket Configuration
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::example-bucket/*"
    }
  ]
}
```

### Versioning
- Preserves multiple variants
- Cannot be disabled once enabled
- Protects against accidental deletion
- Lifecycle management integration

### Lifecycle Rules
```json
{
  "Rules": [
    {
      "ID": "MoveToGlacier",
      "Status": "Enabled",
      "Transition": {
        "Days": 90,
        "StorageClass": "GLACIER"
      }
    }
  ]
}
```

### Replication
- Cross-Region Replication (CRR)
- Same-Region Replication (SRR)
- Requirements:
  - Versioning enabled
  - Proper IAM roles
  - Different destination

## Security

### Bucket Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnencryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::example-bucket/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
```

### Encryption Options
1. Server-Side Encryption
   - SSE-S3 (AES-256)
   - SSE-KMS (AWS KMS)
   - SSE-C (Customer-provided)

2. Client-Side Encryption
   - Client manages keys
   - Data encrypted before upload

### Access Control
- IAM policies
- Bucket policies
- ACLs (legacy)
- Access Points
- Block Public Access

## Performance

### Transfer Acceleration
- Uses CloudFront
- Optimized network paths
- Global edge locations
- Upload speed improvement

### Multipart Upload
```python
# Example multipart upload
import boto3

s3 = boto3.client('s3')
mpu = s3.create_multipart_upload(Bucket='example-bucket', Key='large-file')

# Upload parts
parts = []
for i, part in enumerate(file_parts, 1):
    response = s3.upload_part(
        Bucket='example-bucket',
        Key='large-file',
        PartNumber=i,
        UploadId=mpu['UploadId'],
        Body=part
    )
    parts.append({
        'PartNumber': i,
        'ETag': response['ETag']
    })

# Complete upload
s3.complete_multipart_upload(
    Bucket='example-bucket',
    Key='large-file',
    UploadId=mpu['UploadId'],
    MultipartUpload={'Parts': parts}
)
```

### Event Notifications
- S3 Event Types:
  - ObjectCreated
  - ObjectRemoved
  - ObjectRestore
  - Replication
- Destinations:
  - SNS
  - SQS
  - Lambda

## Monitoring

### CloudWatch Integration
- Request metrics
- Replication metrics
- Storage metrics
- Latency metrics

### Access Logging
```json
{
  "LoggingEnabled": {
    "TargetBucket": "log-bucket",
    "TargetPrefix": "logs/",
    "TargetGrants": [
      {
        "Grantee": {
          "Type": "Group",
          "URI": "http://acs.amazonaws.com/groups/s3/LogDelivery"
        },
        "Permission": "WRITE"
      }
    ]
  }
}
```

### Storage Analytics
- Storage Class Analysis
- S3 Inventory
- Storage Lens
- Usage reports

## Cost Optimization

### Storage Classes Selection
- Access patterns analysis
- Data lifecycle management
- Cost comparison
- Transition rules

### Lifecycle Management
```json
{
  "Rules": [
    {
      "ID": "CostOptimization",
      "Status": "Enabled",
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
      "Expiration": {
        "Days": 365
      }
    }
  ]
}
```

### Best Practices
1. Use appropriate storage class
2. Enable lifecycle policies
3. Monitor usage patterns
4. Implement cost allocation tags
5. Regular cleanup of unused objects 