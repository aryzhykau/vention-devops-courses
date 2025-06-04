# CloudWatch Best Practices

This document outlines best practices for implementing AWS CloudWatch in production environments.

## Metric Collection Best Practices

### 1. Metric Design
```hcl
resource "aws_cloudwatch_metric_alarm" "example" {
  namespace           = "CustomNamespace"
  metric_name        = "ApplicationMetric"
  dimensions = {
    Environment = "Production"
    Service     = "API"
    Component   = "Authentication"
  }
  
  statistic           = "Average"
  period             = "60"
  evaluation_periods = "3"
  threshold          = "90"
  comparison_operator = "GreaterThanThreshold"
}
```

### 2. Resolution Selection
- Standard resolution (1 minute)
- High resolution (1 second)
- Cost vs. granularity trade-offs
- Retention periods

### 3. Dimensions Strategy
- Use consistent naming
- Implement hierarchical dimensions
- Limit dimension combinations
- Consider query patterns

## Alarm Configuration Best Practices

### 1. Threshold Configuration
```hcl
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period            = "300"
  statistic         = "Average"
  threshold         = "80"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions     = [aws_sns_topic.alarm.arn]
}
```

### 2. Composite Alarms
```hcl
resource "aws_cloudwatch_composite_alarm" "service_health" {
  alarm_name = "service-health"
  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.high_cpu.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.high_memory.alarm_name})"

  alarm_actions = [aws_sns_topic.critical.arn]
}
```

### 3. Alarm Actions
- SNS notifications
- Auto Scaling actions
- Systems Manager actions
- Lambda functions

## Log Management Best Practices

### 1. Log Group Configuration
```hcl
resource "aws_cloudwatch_log_group" "application" {
  name              = "/app/production/api"
  retention_in_days = 30
  
  tags = {
    Environment = "Production"
    Application = "API"
  }
}
```

### 2. Metric Filters
```hcl
resource "aws_cloudwatch_log_metric_filter" "error_count" {
  name           = "error-count"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.application.name

  metric_transformation {
    name          = "ErrorCount"
    namespace     = "CustomMetrics"
    value         = "1"
    default_value = "0"
  }
}
```

### 3. Log Insights Queries
```sql
fields @timestamp, @message
| filter @message like /ERROR/
| stats count(*) as error_count by bin(30m)
| sort error_count desc
| limit 100
```

## Container Monitoring Best Practices

### 1. Container Insights Setup
```hcl
resource "aws_ecs_cluster" "main" {
  name = "production-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
```

### 2. Custom Container Metrics
```hcl
resource "aws_cloudwatch_log_group" "container" {
  name              = "/aws/ecs/containerinsights/production-cluster/performance"
  retention_in_days = 30
}

resource "aws_cloudwatch_metric_alarm" "container_memory" {
  alarm_name          = "container-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "MemoryUtilization"
  namespace          = "ECS/ContainerInsights"
  period            = "300"
  statistic         = "Average"
  threshold         = "85"
  
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
  }
}
```

## Synthetic Monitoring Best Practices

### 1. Canary Configuration
```hcl
resource "aws_synthetics_canary" "api" {
  name                 = "api-canary"
  artifact_s3_location = "s3://${aws_s3_bucket.canary.bucket}/artifacts/"
  execution_role_arn   = aws_iam_role.canary.arn
  handler             = "index.handler"
  runtime_version     = "syn-nodejs-puppeteer-3.3"
  
  schedule {
    expression = "rate(5 minutes)"
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.canary.id]
  }
}
```

### 2. Multi-Step Canaries
```javascript
const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');

const flowBuilderBlueprint = async function () {
    // Navigate to page
    await synthetics.executeStep('navigateToPage', async function () {
        await page.goto('https://example.com');
    });

    // Verify login form
    await synthetics.executeStep('verifyLoginForm', async function () {
        await page.waitForSelector('#login-form');
    });

    // Perform login
    await synthetics.executeStep('performLogin', async function () {
        await page.type('#username', process.env.USERNAME);
        await page.type('#password', process.env.PASSWORD);
        await page.click('#submit');
    });
};

exports.handler = async () => {
    return await flowBuilderBlueprint();
};
```

## Dashboard Best Practices

### 1. Dashboard Organization
```hcl
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "service-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization"],
            ["AWS/EC2", "MemoryUtilization"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Resource Utilization"
        }
      },
      {
        type   = "log"
        properties = {
          query   = "fields @timestamp, @message | filter @message like /ERROR/"
          region  = var.aws_region
          title   = "Error Logs"
        }
      }
    ]
  })
}
```

### 2. Cross-Account Monitoring
```hcl
resource "aws_iam_role" "monitoring" {
  name = "cross-account-monitoring"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.monitoring_account_id}:root"
        }
      }
    ]
  })
}
```

## Cost Optimization

### 1. Metric Collection
- Use appropriate resolution
- Implement metric aggregation
- Configure proper retention
- Clean up unused metrics

### 2. Log Management
- Set appropriate retention periods
- Use metric filters effectively
- Implement log aggregation
- Archive old logs to S3

### 3. Container Monitoring
- Enable selective monitoring
- Use appropriate sampling rates
- Configure proper log retention
- Implement metric filtering

## Additional Considerations

### 1. Security
- Use IAM roles effectively
- Implement encryption
- Configure proper access controls
- Monitor security metrics

### 2. Compliance
- Implement audit logging
- Configure retention policies
- Monitor compliance metrics
- Generate compliance reports

### 3. Scalability
- Use metric aggregation
- Implement proper filtering
- Configure appropriate intervals
- Monitor resource limits 