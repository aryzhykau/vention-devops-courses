# CloudTrail Events and Logging Guide

This guide provides detailed information about CloudTrail events, logging configurations, and their implementation.

## Types of Events

### 1. Management Events
- Control plane operations
- API calls that modify AWS resources
- Read and write operations
- Default enabled in trails

Example configuration:
```hcl
resource "aws_cloudtrail" "management_events" {
  name                          = "management-events-trail"
  s3_bucket_name               = aws_s3_bucket.trail.id
  include_global_service_events = true
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
```

### 2. Data Events
- Data plane operations
- High-volume activities
- Object-level API activity
- Disabled by default

Example configuration:
```hcl
resource "aws_cloudtrail" "data_events" {
  name                          = "data-events-trail"
  s3_bucket_name               = aws_s3_bucket.trail.id
  
  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = true
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::my-bucket/"]
    }
    
    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda:${var.region}:${var.account_id}:function:*"]
    }
  }
}
```

### 3. Insights Events
- Unusual API activity detection
- Baseline deviation analysis
- Additional charges apply
- Optional feature

Example configuration:
```hcl
resource "aws_cloudtrail" "insights_events" {
  name                          = "insights-events-trail"
  s3_bucket_name               = aws_s3_bucket.trail.id
  include_global_service_events = true
  
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }
}
```

## Event Record Structure

### 1. Common Fields
```json
{
  "eventVersion": "1.08",
  "userIdentity": {
    "type": "IAMUser",
    "principalId": "AIDAXXXXXXXXXXXXXXXXX",
    "arn": "arn:aws:iam::123456789012:user/username",
    "accountId": "123456789012",
    "userName": "username"
  },
  "eventTime": "2023-01-01T00:00:00Z",
  "eventSource": "s3.amazonaws.com",
  "eventName": "PutObject",
  "awsRegion": "us-west-2"
}
```

### 2. Identity Information
```json
{
  "userIdentity": {
    "type": "AssumedRole",
    "principalId": "AROAXXXXXXXXXXXXXXXXX:session-name",
    "arn": "arn:aws:sts::123456789012:assumed-role/role-name/session-name",
    "accountId": "123456789012",
    "sessionContext": {
      "sessionIssuer": {
        "type": "Role",
        "principalId": "AROAXXXXXXXXXXXXXXXXX",
        "arn": "arn:aws:iam::123456789012:role/role-name",
        "accountId": "123456789012",
        "userName": "role-name"
      },
      "attributes": {
        "creationDate": "2023-01-01T00:00:00Z",
        "mfaAuthenticated": "true"
      }
    }
  }
}
```

## Log File Organization

### 1. S3 Path Structure
```
s3://bucket-name/AWSLogs/account-id/CloudTrail/region/yyyy/mm/dd/
```

Example path:
```
s3://my-cloudtrail-logs/AWSLogs/123456789012/CloudTrail/us-west-2/2023/01/01/
```

### 2. Log File Naming
```
account-id_CloudTrail_region_yyyymmddThhmmZ_unique-string.json.gz
```

Example filename:
```
123456789012_CloudTrail_us-west-2_20230101T0000Z_A1B2C3D4.json.gz
```

## Event Filtering and Processing

### 1. CloudWatch Logs Filter
```hcl
resource "aws_cloudwatch_log_metric_filter" "api_calls" {
  name           = "api-calls"
  pattern        = "[timestamp, eventName, sourceIPAddress, userIdentity.userName]"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name      = "ApiCalls"
    namespace = "CloudTrailMetrics"
    value     = "1"
    dimensions = {
      EventName = "$.eventName"
      UserName  = "$.userIdentity.userName"
    }
  }
}
```

### 2. Athena Query
```sql
CREATE EXTERNAL TABLE cloudtrail_logs (
    eventVersion STRING,
    userIdentity STRUCT<
        type: STRING,
        principalId: STRING,
        arn: STRING,
        accountId: STRING,
        userName: STRING>,
    eventTime STRING,
    eventSource STRING,
    eventName STRING,
    awsRegion STRING
)
ROW FORMAT SERDE 'com.amazon.emr.hive.serde.CloudTrailSerde'
STORED AS INPUTFORMAT 'com.amazon.emr.cloudtrail.CloudTrailInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://my-cloudtrail-logs/AWSLogs/123456789012/CloudTrail/';
```

## Event Response Automation

### 1. EventBridge Rule
```hcl
resource "aws_cloudwatch_event_rule" "suspicious_activity" {
  name        = "detect-suspicious-activity"
  description = "Detect suspicious API calls"

  event_pattern = jsonencode({
    source      = ["aws.cloudtrail"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["iam.amazonaws.com"]
      eventName   = ["DeleteRole", "DeleteUser", "DeletePolicy"]
    }
  })
}
```

### 2. Lambda Function
```hcl
resource "aws_lambda_function" "event_processor" {
  filename      = "event_processor.zip"
  function_name = "cloudtrail-event-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }
}
```

## Best Practices for Event Logging

### 1. Event Selection
- Enable appropriate event types
- Configure selective data events
- Use insights for anomaly detection
- Implement proper filtering

### 2. Log Processing
- Set up real-time processing
- Implement automated analysis
- Configure proper retention
- Enable log validation

### 3. Security Considerations
- Encrypt log files
- Validate file integrity
- Monitor access patterns
- Implement alerts

### 4. Cost Management
- Select appropriate events
- Configure proper retention
- Monitor storage usage
- Optimize queries

## Troubleshooting Guide

### 1. Missing Events
- Check trail configuration
- Verify IAM permissions
- Check S3 bucket policy
- Validate event selectors

### 2. Delivery Issues
- Check S3 bucket permissions
- Verify KMS key access
- Monitor delivery latency
- Check service quotas

### 3. Query Problems
- Validate log format
- Check partition structure
- Optimize query patterns
- Monitor query costs

## Additional Resources

- [CloudTrail Event Reference](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference.html)
- [Log File Structure](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-examples.html)
- [Querying Logs](https://docs.aws.amazon.com/athena/latest/ug/cloudtrail-logs.html)
- [Event Processing](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cloudtrail-events.html) 