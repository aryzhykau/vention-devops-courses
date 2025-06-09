# AWS Lambda Monitoring Guide

## CloudWatch Metrics

### 1. Built-in Metrics
- **Invocations**
  - Total function invocations
  - Success/failure rates
  - Throttles
  - Async delivery failures

- **Performance**
  - Duration
  - Memory usage
  - Concurrent executions
  - Initialization time (cold starts)

- **Error Tracking**
  - Error count and rate
  - Dead letter queue errors
  - Iterator age (stream processing)

### 2. Custom Metrics
```python
# Publishing custom metrics
import boto3

cloudwatch = boto3.client('cloudwatch')

def publish_metric(name, value, unit='Count'):
    cloudwatch.put_metric_data(
        Namespace='CustomLambdaMetrics',
        MetricData=[{
            'MetricName': name,
            'Value': value,
            'Unit': unit,
            'Dimensions': [{
                'Name': 'FunctionName',
                'Value': context.function_name
            }]
        }]
    )
```

### 3. Recommended Alarms
```hcl
# Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.function_name}-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = "1"
  alarm_description  = "Lambda function error rate monitor"
  
  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }
}

# Duration Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.function_name}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "Duration"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Average"
  threshold          = "10000"  # 10 seconds
  alarm_description  = "Lambda function duration monitor"
  
  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }
}
```

## Logging

### 1. Structured Logging
```python
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def log_event(event_type, details):
    logger.info(json.dumps({
        'event_type': event_type,
        'timestamp': datetime.utcnow().isoformat(),
        'details': details
    }))

def handler(event, context):
    log_event('INVOCATION_START', {'event': event})
    try:
        result = process_event(event)
        log_event('INVOCATION_SUCCESS', {'result': result})
        return result
    except Exception as e:
        log_event('INVOCATION_ERROR', {'error': str(e)})
        raise
```

### 2. Log Retention
```hcl
# CloudWatch Log Group with retention
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
  
  tags = {
    Environment = var.environment
    Function    = var.function_name
  }
}
```

### 3. Log Analysis
- Use CloudWatch Logs Insights
- Create custom dashboards
- Set up log subscriptions
- Implement log filtering

## X-Ray Tracing

### 1. Basic Setup
```python
# Enable X-Ray tracing
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

patch_all()  # Patch all supported libraries

@xray_recorder.capture('handler')
def handler(event, context):
    # Function code
    pass
```

### 2. Custom Subsegments
```python
# Adding custom subsegments
def handler(event, context):
    with xray_recorder.capture('process_event') as subsegment:
        subsegment.put_annotation('event_type', event['type'])
        result = process_event(event)
        subsegment.put_metadata('result', result)
    return result
```

### 3. Sampling Rules
```json
{
  "version": 2,
  "rules": [
    {
      "description": "High-value transactions",
      "host": "*",
      "http_method": "*",
      "url_path": "/api/high-value/*",
      "fixed_target": 1,
      "rate": 1.0
    }
  ],
  "default": {
    "fixed_target": 1,
    "rate": 0.1
  }
}
```

## Performance Monitoring

### 1. Cold Start Tracking
```python
import time

def handler(event, context):
    start_time = time.time()
    
    # Function code
    
    duration = time.time() - start_time
    publish_metric('ExecutionTime', duration, 'Milliseconds')
    
    # Track if this was a cold start
    if not hasattr(handler, 'initialized'):
        publish_metric('ColdStart', 1)
        handler.initialized = True
```

### 2. Memory Usage
```python
import psutil

def track_memory():
    memory = psutil.Process().memory_info().rss / 1024 / 1024  # MB
    publish_metric('MemoryUsage', memory, 'Megabytes')
```

### 3. Concurrent Execution
```hcl
# Monitor concurrent executions
resource "aws_cloudwatch_metric_alarm" "concurrent_executions" {
  alarm_name          = "${var.function_name}-concurrent-executions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "ConcurrentExecutions"
  namespace          = "AWS/Lambda"
  period             = "60"
  statistic          = "Maximum"
  threshold          = var.max_concurrent_executions
  alarm_description  = "Monitor concurrent Lambda executions"
}
```

## Cost Monitoring

### 1. Usage Metrics
- Track invocation count
- Monitor execution duration
- Calculate GB-seconds
- Monitor provisioned concurrency

### 2. Cost Allocation
```hcl
# Tags for cost tracking
resource "aws_lambda_function" "main" {
  # ... other configuration ...
  
  tags = {
    Environment = var.environment
    CostCenter  = var.cost_center
    Project     = var.project_name
  }
}
```

### 3. Budget Alerts
```hcl
# AWS Budget for Lambda costs
resource "aws_budgets_budget" "lambda" {
  name         = "lambda-monthly-budget"
  budget_type  = "COST"
  limit_amount = "100"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  
  cost_filter {
    name = "Service"
    values = ["AWS Lambda"]
  }
  
  notification {
    comparison_operator = "GREATER_THAN"
    threshold          = 80
    threshold_type     = "PERCENTAGE"
    notification_type  = "ACTUAL"
  }
}
```

## Dashboard Creation

### 1. Basic Dashboard
```hcl
resource "aws_cloudwatch_dashboard" "lambda" {
  dashboard_name = "${var.function_name}-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.function_name],
            ["AWS/Lambda", "Errors", "FunctionName", var.function_name],
            ["AWS/Lambda", "Duration", "FunctionName", var.function_name],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", var.function_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Lambda Function Metrics"
        }
      }
    ]
  })
}
```

### 2. Advanced Visualizations
- Create custom widgets
- Add error rate graphs
- Include cost metrics
- Visualize cold starts 