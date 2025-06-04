# CloudWatch Troubleshooting Guide

This guide provides solutions for common issues encountered with AWS CloudWatch and its components.

## Common Issues and Solutions

### 1. Missing Metrics

#### Problem: Metrics not appearing in CloudWatch
```
No data points found for specified metrics
```

**Solutions:**
1. Check IAM permissions:
```hcl
resource "aws_iam_role_policy" "cloudwatch" {
  name = "cloudwatch-policy"
  role = aws_iam_role.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })
}
```

2. Verify metric namespace and dimensions:
```bash
aws cloudwatch list-metrics \
  --namespace "AWS/EC2" \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0
```

3. Check metric resolution and timing:
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time $(date -d '1 hour ago' -u +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 300 \
  --statistics Average
```

### 2. Alarm Issues

#### Problem: Alarms not triggering
```
Alarm state not changing despite threshold breach
```

**Solutions:**
1. Check alarm configuration:
```hcl
resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name          = "test-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period            = "300"
  statistic         = "Average"
  threshold         = "80"
  
  dimensions = {
    InstanceId = aws_instance.example.id
  }

  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions     = [aws_sns_topic.alarm.arn]
}
```

2. Verify SNS topic and subscriptions:
```hcl
resource "aws_sns_topic" "alarm" {
  name = "alarm-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = "user@example.com"
}
```

3. Check alarm history:
```bash
aws cloudwatch describe-alarm-history \
  --alarm-name "test-alarm" \
  --history-item-type StateUpdate
```

### 3. Log Issues

#### Problem: Logs not appearing
```
No log events found in specified log group
```

**Solutions:**
1. Check log group configuration:
```hcl
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/function"
  retention_in_days = 14
  
  tags = {
    Environment = "Production"
    Application = "Example"
  }
}
```

2. Verify IAM permissions:
```hcl
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name = "cloudwatch-logs-policy"
  role = aws_iam_role.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
```

3. Check log agent configuration:
```json
{
  "agent": {
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/application.log",
            "log_group_name": "/aws/application",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
```

### 4. Dashboard Issues

#### Problem: Dashboard widgets not updating
```
Widget data not refreshing or showing stale data
```

**Solutions:**
1. Check widget configuration:
```hcl
resource "aws_cloudwatch_dashboard" "example" {
  dashboard_name = "example-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 CPU Utilization"
        }
      }
    ]
  })
}
```

2. Verify metric data availability:
```bash
aws cloudwatch get-metric-data \
  --metric-data-queries '[
    {
      "Id": "cpu",
      "MetricStat": {
        "Metric": {
          "Namespace": "AWS/EC2",
          "MetricName": "CPUUtilization",
          "Dimensions": [
            {
              "Name": "InstanceId",
              "Value": "i-1234567890"
            }
          ]
        },
        "Period": 300,
        "Stat": "Average"
      }
    }
  ]' \
  --start-time $(date -d '1 hour ago' -u +%FT%TZ) \
  --end-time $(date -u +%FT%TZ)
```

### 5. Container Insights Issues

#### Problem: Container metrics not available
```
No container metrics appearing in CloudWatch
```

**Solutions:**
1. Check Container Insights setup:
```hcl
resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
```

2. Verify CloudWatch agent configuration:
```yaml
agent:
  region: "us-west-2"
logs:
  metrics_collected:
    containers:
      metrics_collection_interval: 60
      cluster_name: "example-cluster"
      container_insights: true
```

## Diagnostic Tools

### 1. CloudWatch Logs Insights
```sql
# Find error patterns
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 20

# Analyze latency
fields @timestamp, @message
| filter @message like /Latency/
| stats avg(latency) as avg_latency by bin(5m)
| sort avg_latency desc
```

### 2. Metric Math
```hcl
resource "aws_cloudwatch_dashboard" "diagnostic" {
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            [{
              expression = "ANOMALY_DETECTION_BAND(m1, 2)",
              label = "Expected Range"
            }],
            ["AWS/EC2", "CPUUtilization", { id = "m1" }]
          ]
        }
      }
    ]
  })
}
```

## Best Practices

### 1. Monitoring Setup
- Use appropriate metric resolution
- Configure proper retention periods
- Implement metric aggregation
- Set up proper alerting

### 2. Log Management
- Configure proper log retention
- Use structured logging
- Implement log aggregation
- Set up metric filters

### 3. Alarm Configuration
- Set appropriate thresholds
- Use proper evaluation periods
- Configure composite alarms
- Implement proper actions

### 4. Performance Optimization
- Use efficient queries
- Implement proper filtering
- Configure appropriate intervals
- Monitor resource limits

## Additional Resources

- [CloudWatch Troubleshooting Guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Troubleshooting.html)
- [Container Insights Troubleshooting](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights_Troubleshooting.html)
- [CloudWatch Logs Troubleshooting](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch-Logs-Troubleshooting.html)
- [Metric Alarms Troubleshooting](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmTroubleshooting.html) 