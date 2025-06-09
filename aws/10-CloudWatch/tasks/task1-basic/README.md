# Task 1: Basic CloudWatch Setup

This task implements a basic CloudWatch monitoring setup with alarms, logs, metrics, and dashboards.

## Components

1. SNS Topic and Subscription
   - Alert notifications via email
   - Configurable email endpoint

2. CloudWatch Log Group
   - Application log collection
   - Configurable retention period
   - Environment-based naming

3. Metric Alarms
   - CPU utilization monitoring
   - Memory utilization monitoring
   - Disk space monitoring
   - Error count monitoring

4. Log Metric Filter
   - Error log pattern matching
   - Custom metric creation
   - Error count aggregation

5. Dashboard
   - Resource utilization widgets
   - Error count visualization
   - Error log display

## Prerequisites

1. AWS Provider Configuration
```hcl
provider "aws" {
  region = var.aws_region
}
```

2. Existing Auto Scaling Group
   - The ASG name is required for resource monitoring

3. IAM Permissions
   - CloudWatch full access
   - SNS publish permissions
   - Log group creation and management

## Usage

1. Initialize the module:
```bash
terraform init
```

2. Create a `terraform.tfvars` file:
```hcl
aws_region       = "us-west-2"
environment      = "production"
application_name = "my-app"
asg_name         = "my-app-asg"
alert_email      = "alerts@example.com"
```

3. Apply the configuration:
```bash
terraform plan
terraform apply
```

## Configuration

### Required Variables
- `asg_name`: Name of the Auto Scaling Group to monitor
- `alert_email`: Email address for CloudWatch alerts

### Optional Variables
- `aws_region`: AWS region (default: "us-west-2")
- `environment`: Environment name (default: "production")
- `application_name`: Application name (default: "example-app")
- `log_retention_days`: Log retention period (default: 30)
- `cpu_threshold`: CPU alarm threshold (default: 80)
- `memory_threshold`: Memory alarm threshold (default: 80)
- `disk_threshold`: Disk space alarm threshold (default: 85)
- `error_threshold`: Error count threshold (default: 10)

## Outputs

- `sns_topic_arn`: ARN of the SNS topic
- `log_group_name`: Name of the CloudWatch log group
- `log_group_arn`: ARN of the CloudWatch log group
- `dashboard_name`: Name of the CloudWatch dashboard
- `dashboard_arn`: ARN of the CloudWatch dashboard
- `metric_alarms`: Map of metric alarm ARNs
- `metric_filter_name`: Name of the error log metric filter
- `alert_subscription_arn`: ARN of the SNS subscription

## Dashboard Layout

The dashboard includes three main widgets:

1. Resource Utilization (Top Left)
   - CPU utilization
   - Memory utilization
   - Disk space utilization

2. Application Errors (Top Right)
   - Error count metrics
   - Trend visualization

3. Error Logs (Bottom)
   - Recent error messages
   - Timestamp and details

## Alarm Actions

When an alarm is triggered:
1. Notification is sent to the SNS topic
2. Email is sent to the specified address
3. Alarm state is recorded in CloudWatch

## Log Management

1. Log Collection
   - Application logs are collected in the specified log group
   - Logs are retained according to the retention period

2. Error Detection
   - Error patterns are matched using the metric filter
   - Matched patterns generate custom metrics
   - Custom metrics trigger alarms when thresholds are exceeded

## Validation Steps

1. Verify SNS Topic
```bash
aws sns list-subscriptions-by-topic --topic-arn <sns_topic_arn>
```

2. Check Log Group
```bash
aws logs describe-log-groups --log-group-name-prefix /aws/application
```

3. View Alarms
```bash
aws cloudwatch describe-alarms --alarm-names high-cpu-utilization high-memory-utilization high-disk-utilization high-error-count
```

4. Test Dashboard
```bash
aws cloudwatch get-dashboard --dashboard-name <dashboard_name>
```

## Common Issues and Solutions

1. Missing Metrics
   - Verify CloudWatch agent installation
   - Check IAM permissions
   - Validate metric namespace

2. Alarm Not Triggering
   - Review threshold settings
   - Check evaluation periods
   - Verify SNS permissions

3. Log Collection Issues
   - Check log agent configuration
   - Verify IAM permissions
   - Review log group settings

## Additional Resources

- [CloudWatch Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html)
- [CloudWatch Logs Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html)
- [SNS Documentation](https://docs.aws.amazon.com/sns/latest/dg/welcome.html)
- [CloudWatch Metrics Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html) 