# Task 3: Data Lifecycle Management

This task demonstrates implementing S3 lifecycle management policies and data replication for cost optimization and disaster recovery.

## Objectives
1. Configure lifecycle rules for different storage classes
2. Set up cross-region replication
3. Implement object expiration policies
4. Configure versioning management
5. Set up storage analytics

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured
- Basic understanding of S3 storage classes

## Implementation Steps

### 1. Storage Classes Configuration
- Set up standard storage
- Configure Intelligent-Tiering
- Set up Standard-IA
- Configure Glacier transitions

### 2. Lifecycle Rules
```json
{
  "Rules": [
    {
      "ID": "MoveToIA",
      "Status": "Enabled",
      "Prefix": "documents/",
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        }
      ]
    },
    {
      "ID": "MoveToGlacier",
      "Status": "Enabled",
      "Prefix": "archives/",
      "Transitions": [
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
```

### 3. Replication Setup
- Enable versioning
- Create destination bucket
- Configure IAM roles
- Set up replication rules

### 4. Analytics Configuration
- Enable Storage Lens
- Set up S3 Analytics
- Configure metrics
- Set up notifications

### 5. Cost Optimization
- Configure expiration rules
- Set up cleanup policies
- Implement tagging
- Monitor costs

## Architecture Diagram
```
                    Primary Region
                         |
                    Main Bucket
                    /    |    \
            Standard  IA   Glacier
                |
        Secondary Region
                |
          Replica Bucket
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

4. Test lifecycle rules:
```bash
# Upload test files
aws s3 cp test.txt s3://your-bucket-name/documents/
aws s3 cp archive.zip s3://your-bucket-name/archives/
```

## Validation Steps

1. Check Lifecycle Rules:
```bash
aws s3api get-bucket-lifecycle-configuration --bucket your-bucket-name
```

2. Verify Replication:
```bash
aws s3api get-bucket-replication --bucket your-bucket-name
```

3. Monitor Transitions:
```bash
# List objects with storage class
aws s3api list-objects-v2 --bucket your-bucket-name --query 'Contents[].{Key: Key, StorageClass: StorageClass}'
```

4. Check Analytics:
```bash
aws s3api get-bucket-analytics-configuration --bucket your-bucket-name
```

## Cleanup

To remove all resources:
```bash
# Remove all objects from buckets first
aws s3 rm s3://your-bucket-name --recursive
aws s3 rm s3://your-replica-bucket-name --recursive

# Destroy infrastructure
terraform destroy
```

## Additional Notes
- Lifecycle transitions take time to complete
- Monitor storage costs regularly
- Keep track of object versions
- Review analytics data
- Adjust rules as needed

## Troubleshooting

### Common Issues
1. Transition delays
   - Check rule configuration
   - Verify object eligibility
   - Monitor transition status

2. Replication issues
   - Verify IAM roles
   - Check versioning status
   - Review replication rules

3. Cost optimization
   - Monitor storage classes
   - Review transition rules
   - Check expiration policies

### Logs Location
- S3 access logs
- CloudWatch metrics
- Storage Lens dashboard
- Replication metrics

### Useful Commands
```bash
# Check object storage class
aws s3api head-object --bucket your-bucket-name --key your-object-key

# List object versions
aws s3api list-object-versions --bucket your-bucket-name

# Get replication metrics
aws s3api get-bucket-metrics-configuration --bucket your-bucket-name
```

### Best Practices
1. Regular cost analysis
2. Monitor transition metrics
3. Review storage patterns
4. Adjust rules based on usage
5. Document policies 