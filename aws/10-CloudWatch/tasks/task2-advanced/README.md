# Task 2: Advanced CloudWatch Monitoring

This task implements advanced CloudWatch monitoring features including metric streams, anomaly detection, composite alarms, and cross-account monitoring.

## Components

1. Metric Streaming
   - CloudWatch metric streams
   - Kinesis Firehose delivery
   - S3 metric storage
   - Custom metric namespaces

2. Advanced Alarms
   - Anomaly detection
   - Composite alarms
   - Metric math
   - Cross-account monitoring

3. Advanced Dashboard
   - Anomaly detection bands
   - Metric math visualizations
   - Custom widget layouts
   - Real-time updates

## Prerequisites

1. AWS Provider Configuration
```hcl
provider "aws" {
  region = var.aws_region
}
```

2. Required Resources
   - API Gateway
   - Auto Scaling Group
   - Cross-account access

3. IAM Permissions
   - CloudWatch full access
   - Kinesis Firehose access
   - S3 bucket access
   - Cross-account assume role

## Usage

1. Initialize the module:
```bash
terraform init
```

2. Create a `terraform.tfvars` file:
```hcl
aws_region           = "us-west-2"
environment          = "production"
api_name             = "my-api"
asg_name             = "my-app-asg"
monitoring_account_id = "123456789012"
```

3. Apply the configuration:
```bash
terraform plan
terraform apply
```

## Configuration

### Required Variables
- `api_name`: Name of the API Gateway to monitor
- `asg_name`: Name of the Auto Scaling Group to monitor
- `monitoring_account_id`: AWS account ID for cross-account monitoring

### Optional Variables
- `aws_region`: AWS region (default: "us-west-2")
- `environment`: Environment name (default: "production")
- `metric_stream_include_filters`: Namespaces to include in metric stream
- `anomaly_detection_threshold`: Standard deviations for anomaly detection
- `error_rate_threshold`: Error rate alarm threshold
- `evaluation_periods`: Number of evaluation periods
- `metric_period`: Metric aggregation period
- `cpu_threshold`: CPU utilization threshold
- `metric_retention_days`: Metric retention in S3
- `dashboard_refresh_interval`: Dashboard refresh interval
- `tags`: Resource tags

## Outputs

- `metric_stream_arn`: ARN of the metric stream
- `firehose_arn`: ARN of the Kinesis Firehose
- `metrics_bucket_name`: Name of the metrics S3 bucket
- `composite_alarm_arn`: ARN of the composite alarm
- `metric_alarms`: Map of metric alarm ARNs
- `monitoring_role_arn`: ARN of the monitoring role
- `dashboard_name`: Name of the dashboard
- `dashboard_arn`: ARN of the dashboard
- `sns_topic_arn`: ARN of the SNS topic

## Features

### 1. Metric Streaming
- Real-time metric delivery to S3
- Configurable namespaces
- Structured data format
- Historical metric storage

### 2. Anomaly Detection
- Machine learning-based detection
- Configurable thresholds
- Automatic baseline learning
- Dynamic adaptation

### 3. Composite Alarms
- Complex alarm conditions
- Multiple metric correlation
- Logical operators
- Nested conditions

### 4. Cross-Account Monitoring
- Secure role assumption
- Limited permissions
- Centralized monitoring
- Multi-account visibility

## Dashboard Layout

1. API Performance (Top Left)
   - Latency metrics
   - Anomaly detection bands
   - Historical trends

2. Error Analysis (Top Right)
   - Error rate calculation
   - Request count correlation
   - Threshold visualization

3. Resource Utilization (Bottom)
   - CPU usage patterns
   - Anomaly detection
   - Capacity analysis

## Validation Steps

1. Verify Metric Stream
```bash
aws cloudwatch list-metric-streams
```

2. Check Firehose Delivery
```bash
aws firehose describe-delivery-stream \
  --delivery-stream-name cloudwatch-metrics-stream
```

3. Test Cross-Account Access
```bash
aws sts assume-role \
  --role-arn <monitoring_role_arn> \
  --role-session-name monitoring-session
```

4. View Composite Alarm
```bash
aws cloudwatch describe-alarms \
  --alarm-names service-health
```

## Common Issues and Solutions

1. Metric Stream Issues
   - Verify IAM permissions
   - Check Firehose configuration
   - Validate S3 bucket policy
   - Monitor delivery errors

2. Anomaly Detection
   - Ensure sufficient data history
   - Adjust detection threshold
   - Review learning period
   - Check metric frequency

3. Cross-Account Access
   - Verify role trust relationship
   - Check permission boundaries
   - Validate assume role policy
   - Test role assumption

## Best Practices

1. Metric Collection
   - Use appropriate namespaces
   - Configure proper retention
   - Implement metric aggregation
   - Monitor stream health

2. Alarm Configuration
   - Set meaningful thresholds
   - Use appropriate periods
   - Configure proper actions
   - Test alarm conditions

3. Dashboard Design
   - Group related metrics
   - Use appropriate visualizations
   - Configure refresh intervals
   - Add meaningful annotations

4. Security
   - Implement least privilege
   - Enable encryption
   - Monitor access patterns
   - Regular permission review

## Additional Resources

- [Metric Streams Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html)
- [Anomaly Detection Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Anomaly_Detection.html)
- [Composite Alarms Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Create_Composite_Alarm.html)
- [Cross-Account Access Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Cross-Account-Cross-Region.html) 