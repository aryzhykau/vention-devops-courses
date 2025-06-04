# Task 1: Basic Bucket Management

This task demonstrates setting up a secure S3 bucket with basic configurations using Terraform.

## Objectives
1. Create a secure S3 bucket
2. Configure bucket policies
3. Set up versioning
4. Implement server-side encryption
5. Configure access logging

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured
- Basic understanding of S3 concepts

## Implementation Steps

### 1. Bucket Creation
- Create a new S3 bucket
- Block public access
- Enable versioning
- Configure encryption

### 2. Security Configuration
```hcl
# Example bucket policy
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

### 3. Access Logging
- Create logging bucket
- Configure log delivery
- Set retention policy
- Monitor access patterns

### 4. Versioning
- Enable versioning
- Configure lifecycle rules
- Set up transitions
- Implement expiration

### 5. Encryption
- Configure SSE-S3
- Set up KMS integration
- Implement bucket policy
- Validate encryption

## Architecture Diagram
```
                   AWS Cloud
                      |
                   S3 Bucket
                   /        \
            Versioning    Encryption
                |            |
          Lifecycle      KMS Key
                |
           Log Bucket
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

4. Test bucket access:
```bash
aws s3 cp test.txt s3://your-bucket-name/
```

## Validation Steps

1. Check Bucket Configuration:
```bash
aws s3api get-bucket-versioning --bucket your-bucket-name
aws s3api get-bucket-encryption --bucket your-bucket-name
```

2. Verify Access Logging:
```bash
aws s3api get-bucket-logging --bucket your-bucket-name
```

3. Test Object Operations:
```bash
# Upload object
aws s3 cp test.txt s3://your-bucket-name/

# List versions
aws s3api list-object-versions --bucket your-bucket-name

# Download specific version
aws s3api get-object --bucket your-bucket-name --key test.txt --version-id "version-id" test-download.txt
```

## Cleanup

To remove all resources:
```bash
terraform destroy
```

## Additional Notes
- Keep bucket names unique
- Monitor storage costs
- Review access logs
- Implement tagging
- Consider encryption needs

## Troubleshooting

### Common Issues
1. Bucket name conflicts
   - Use unique names
   - Check existing buckets
   - Follow naming conventions

2. Permission issues
   - Check IAM roles
   - Verify bucket policy
   - Review access logs

3. Encryption errors
   - Validate KMS access
   - Check encryption settings
   - Review bucket policy

### Logs Location
- Access logs: Configured log bucket
- CloudTrail logs: CloudWatch Logs
- Error logs: CloudWatch Logs

### Useful Commands
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket your-bucket-name

# List objects
aws s3 ls s3://your-bucket-name

# Check encryption
aws s3api get-bucket-encryption --bucket your-bucket-name
``` 