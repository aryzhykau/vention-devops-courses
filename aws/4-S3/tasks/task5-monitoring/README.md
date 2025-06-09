# Task 5: Monitoring and Performance Optimization

This task demonstrates implementing comprehensive monitoring and performance optimization for S3 buckets.

## Objectives
1. Set up CloudWatch monitoring
2. Configure S3 Storage Lens
3. Implement performance optimization
4. Set up cost analysis
5. Create monitoring dashboards

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured
- Basic understanding of AWS monitoring services

## Implementation Steps

### 1. CloudWatch Setup
- Configure metrics
- Set up alarms
- Create dashboards
- Enable detailed monitoring

### 2. Storage Lens Configuration
```json
{
  "Id": "example-storage-lens",
  "StorageLensConfiguration": {
    "Id": "example-configuration",
    "Enabled": true,
    "AccountLevel": {
      "ActivityMetrics": {
        "IsEnabled": true
      },
      "BucketLevel": {
        "ActivityMetrics": {
          "IsEnabled": true
        },
        "PrefixLevel": {
          "StorageMetrics": {
            "IsEnabled": true,
            "SelectionCriteria": {
              "MaxDepth": 5,
              "MinStorageBytesPercentage": 1.0
            }
          }
        }
      }
    }
  }
}
```

### 3. Performance Optimization
- Configure request routing
- Set up transfer acceleration
- Implement caching
- Optimize object naming

### 4. Cost Analysis
- Set up cost allocation tags
- Configure budget alerts
- Monitor usage patterns
- Implement cost controls

### 5. Dashboard Creation
- Create metrics views
- Set up performance graphs
- Configure alerts
- Implement reporting

## Architecture Diagram
```
                CloudWatch
                    |
                S3 Bucket
                /   |   \
        Storage   Cost   Performance
         Lens    Explorer  Metrics
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

4. Test monitoring:
```bash
# Generate test load
for i in {1..100}; do
  aws s3 cp test.txt s3://your-bucket-name/test-$i.txt
done
```

## Validation Steps

1. Check CloudWatch Metrics:
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name NumberOfObjects \
  --dimensions Name=BucketName,Value=your-bucket-name \
  --start-time $(date -u -v-1H +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 3600 \
  --statistics Average
```

2. View Storage Lens:
```bash
aws s3control get-storage-lens-configuration \
  --account-id your-account-id \
  --config-id example-storage-lens
```

3. Check Transfer Acceleration:
```bash
aws s3api get-bucket-accelerate-configuration \
  --bucket your-bucket-name
```

4. Monitor Performance:
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name FirstByteLatency \
  --dimensions Name=BucketName,Value=your-bucket-name \
  --start-time $(date -u -v-1H +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 300 \
  --statistics Average
```

## Cleanup

To remove all resources:
```bash
# Remove all objects from bucket
aws s3 rm s3://your-bucket-name --recursive

# Destroy infrastructure
terraform destroy
```

## Additional Notes
- Monitor metrics regularly
- Adjust thresholds as needed
- Review cost reports
- Optimize based on usage
- Document findings

## Troubleshooting

### Common Issues
1. Metric delays
   - Check collection settings
   - Verify metric filters
   - Review sampling rates

2. Performance issues
   - Check request patterns
   - Verify object sizes
   - Review access patterns

3. Cost spikes
   - Monitor usage patterns
   - Check data transfer
   - Review storage classes

### Logs Location
- CloudWatch logs
- S3 access logs
- Storage Lens dashboard
- Cost Explorer reports

### Useful Commands
```bash
# Get bucket metrics
aws cloudwatch list-metrics --namespace AWS/S3 --dimensions Name=BucketName,Value=your-bucket-name

# Check request metrics
aws s3api get-metric-statistics --metric-name RequestCount --namespace AWS/S3

# View cost allocation
aws ce get-cost-and-usage --time-period Start=2023-01-01,End=2023-12-31 --granularity MONTHLY --metrics "BlendedCost" "UnblendedCost" "UsageQuantity"
```

### Performance Best Practices
1. Use appropriate storage class
2. Implement request routing
3. Enable transfer acceleration
4. Monitor performance metrics
5. Regular optimization reviews 