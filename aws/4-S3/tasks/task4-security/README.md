# Task 4: Security Implementation

This task demonstrates implementing comprehensive security controls for S3 buckets using various AWS security features.

## Objectives
1. Configure bucket policies and IAM roles
2. Set up encryption with KMS
3. Implement access points
4. Configure VPC endpoints
5. Set up advanced logging and monitoring

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured
- Basic understanding of AWS security concepts

## Implementation Steps

### 1. IAM Configuration
- Create service roles
- Set up user policies
- Configure bucket policies
- Implement least privilege

### 2. Encryption Setup
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RequireKMSEncryption",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::example-bucket/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    }
  ]
}
```

### 3. Access Points
- Create access points
- Configure VPC restrictions
- Set up policies
- Implement network controls

### 4. VPC Endpoint
- Create VPC endpoint
- Configure route tables
- Set up endpoint policies
- Implement security groups

### 5. Monitoring Setup
- Configure CloudTrail
- Set up CloudWatch
- Enable access logging
- Configure alerts

## Architecture Diagram
```
                    VPC
                     |
              VPC Endpoint
                     |
                 S3 Bucket
                /    |    \
         Access    KMS    CloudTrail
         Point     Key      Logs
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

4. Test security controls:
```bash
# Test encryption
aws s3 cp test.txt s3://your-bucket-name/ --sse aws:kms

# Test access point
aws s3api get-object --key test.txt --bucket arn:aws:s3:region:account:accesspoint/example
```

## Validation Steps

1. Check Bucket Policy:
```bash
aws s3api get-bucket-policy --bucket your-bucket-name
```

2. Verify Encryption:
```bash
aws s3api get-bucket-encryption --bucket your-bucket-name
```

3. Test VPC Access:
```bash
aws s3 ls s3://your-bucket-name --endpoint-url https://bucket.vpce-id.s3.region.vpce.amazonaws.com
```

4. Verify Access Points:
```bash
aws s3control get-access-point --account-id your-account-id --name example
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
- Review IAM policies regularly
- Monitor access patterns
- Update security controls
- Check compliance requirements
- Document configurations

## Troubleshooting

### Common Issues
1. Access denied errors
   - Check IAM policies
   - Verify bucket policy
   - Review access point settings

2. Encryption issues
   - Verify KMS permissions
   - Check encryption settings
   - Review bucket policy

3. VPC connectivity
   - Check endpoint configuration
   - Verify route tables
   - Review security groups

### Logs Location
- CloudTrail logs
- CloudWatch logs
- S3 access logs
- VPC flow logs

### Useful Commands
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket your-bucket-name

# List access points
aws s3control list-access-points --account-id your-account-id

# Test VPC endpoint
aws s3api list-objects --bucket your-bucket-name --endpoint-url your-vpc-endpoint
```

### Security Best Practices
1. Enable encryption at rest
2. Implement least privilege
3. Use VPC endpoints
4. Enable logging
5. Regular security audits 