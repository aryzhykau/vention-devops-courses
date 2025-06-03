# Task 1: Basic CloudTrail Setup

This task implements a basic CloudTrail configuration with essential logging, monitoring, and alerting capabilities.

## Components

1. CloudTrail Configuration
   - Multi-region trail
   - Management events logging
   - Log file validation
   - CloudWatch Logs integration

2. S3 Bucket Setup
   - Secure bucket configuration
   - Versioning enabled
   - Server-side encryption
   - Appropriate bucket policy

3. CloudWatch Integration
   - Log group creation
   - Metric filters
   - Root account monitoring
   - Custom metrics

4. SNS Notifications
   - Alert topic creation
   - Notification delivery
   - Policy configuration
   - Email subscriptions

## Prerequisites

1. AWS Provider Configuration
```hcl
provider "aws" {
  region = var.aws_region
}
```

2. Required Permissions
   - CloudTrail full access
   - S3 bucket management
   - CloudWatch Logs access
   - SNS topic management
   - IAM role creation

## Usage

1. Initialize the module:
```bash
terraform init
```

2. Create a `terraform.tfvars` file:
```hcl
aws_region         = "us-west-2"
environment        = "production"
notification_email = "alerts@example.com"
```

3. Apply the configuration:
```bash
terraform plan
terraform apply
```

## Configuration

### Required Variables
- `environment`: Environment name (e.g., production, staging)
- `notification_email`: Email address for notifications

### Optional Variables
- `aws_region`: AWS region (default: "us-west-2")
- `log_retention_days`: CloudWatch logs retention (default: 30)
- `enable_log_file_validation`: Enable log validation (default: true)
- `include_global_service_events`: Include global events (default: true)
- `is_multi_region_trail`: Enable multi-region (default: true)
- `enable_logging`: Enable logging (default: true)
- `allow_s3_force_destroy`: Allow bucket force destroy (default: false)
- `tags`: Additional resource tags (default: {})

## Outputs

- `cloudtrail_arn`: ARN of the CloudTrail trail
- `cloudtrail_home_region`: Home region of the trail
- `cloudtrail_id`: ID of the trail
- `s3_bucket_name`: Name of the S3 bucket
- `s3_bucket_arn`: ARN of the S3 bucket
- `cloudwatch_log_group_name`: Name of the log group
- `cloudwatch_log_group_arn`: ARN of the log group
- `sns_topic_arn`: ARN of the SNS topic
- `cloudtrail_role_arn`: ARN of the CloudTrail IAM role
- `metric_filter_id`: ID of the root usage metric filter
- `alarm_arn`: ARN of the root usage alarm
- `log_delivery_status`: Status of log delivery
- `included_management_events`: Management events configuration

## Features

### 1. Logging Configuration
- Management events logging
- Multi-region coverage
- Global service events
- Log file validation

### 2. Storage Setup
- Secure S3 bucket
- Versioning enabled
- Encryption configured
- Access policies

### 3. Monitoring
- CloudWatch integration
- Metric filters
- Custom metrics
- Root account monitoring

### 4. Alerting
- SNS notifications
- Email delivery
- Root access alerts
- Custom alarms

## Validation Steps

1. Verify Trail Status
```bash
aws cloudtrail get-trail-status \
  --name main-trail-${var.environment}
```

2. Check S3 Bucket
```bash
aws s3 ls s3://${aws_s3_bucket.trail.id}/AWSLogs/
```

3. View CloudWatch Logs
```bash
aws logs get-log-events \
  --log-group-name /aws/cloudtrail/${var.environment} \
  --log-stream-name $(aws logs describe-log-streams \
    --log-group-name /aws/cloudtrail/${var.environment} \
    --limit 1 \
    --order-by LastEventTime \
    --descending \
    --query 'logStreams[0].logStreamName' \
    --output text)
```

4. Test SNS Topic
```bash
aws sns list-subscriptions-by-topic \
  --topic-arn ${aws_sns_topic.cloudtrail.arn}
```

## Common Issues and Solutions

1. Log Delivery Issues
   - Check S3 bucket permissions
   - Verify CloudTrail service role
   - Validate bucket policy
   - Check encryption settings

2. CloudWatch Integration
   - Verify IAM role permissions
   - Check log group settings
   - Validate metric filters
   - Monitor log delivery

3. SNS Notifications
   - Confirm subscription
   - Check topic policy
   - Verify email delivery
   - Test notifications

## Security Considerations

1. Access Control
   - Least privilege access
   - Bucket policies
   - IAM role configuration
   - Log encryption

2. Monitoring
   - Root account usage
   - Security events
   - API activity
   - Resource changes

3. Compliance
   - Log retention
   - File validation
   - Access tracking
   - Audit requirements

## Additional Resources

- [CloudTrail Documentation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html)
- [S3 Bucket Security](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
- [CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html)
- [SNS Notifications](https://docs.aws.amazon.com/sns/latest/dg/welcome.html) 