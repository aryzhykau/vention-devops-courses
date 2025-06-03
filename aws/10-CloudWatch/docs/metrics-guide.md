# CloudWatch Metrics and Dimensions Guide

This guide provides detailed information about CloudWatch metrics, dimensions, and their implementation.

## Types of Metrics

### 1. Standard Metrics
- Built-in AWS service metrics
- 5-minute intervals (basic monitoring)
- 1-minute intervals (detailed monitoring)
- No additional cost for basic monitoring

### 2. Custom Metrics
- User-defined metrics
- Standard resolution (1 minute)
- High resolution (1 second)
- Custom namespaces

### 3. High-Resolution Metrics
```hcl
resource "aws_cloudwatch_metric_alarm" "high_resolution" {
  alarm_name          = "high-resolution-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name        = "CustomMetric"
  namespace          = "CustomNamespace"
  period            = "10"  # 10-second periods
  statistic         = "Average"
  threshold         = "90"
  
  dimensions = {
    Service = "API"
  }
}
```

## Metric Namespaces

### 1. AWS Service Namespaces
- AWS/EC2
- AWS/RDS
- AWS/Lambda
- AWS/ECS
- AWS/EKS
- AWS/S3
- AWS/DynamoDB

### 2. Custom Namespaces
```hcl
resource "aws_cloudwatch_metric_alarm" "custom_namespace" {
  namespace           = "MyApplication"
  metric_name        = "ProcessingTime"
  dimensions = {
    Service     = "OrderProcessing"
    Environment = "Production"
  }
}
```

## Dimensions

### 1. Dimension Design
```hcl
resource "aws_cloudwatch_metric_alarm" "with_dimensions" {
  alarm_name          = "api-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name        = "Latency"
  namespace          = "AWS/ApiGateway"
  
  dimensions = {
    ApiName     = var.api_name
    Stage       = var.stage_name
    Method      = "POST"
    Resource    = "/orders"
  }
}
```

### 2. Hierarchical Dimensions
```hcl
# Top-level dimension
resource "aws_cloudwatch_metric_alarm" "service_level" {
  dimensions = {
    Service = "OrderService"
  }
}

# Mid-level dimension
resource "aws_cloudwatch_metric_alarm" "component_level" {
  dimensions = {
    Service   = "OrderService"
    Component = "PaymentProcessor"
  }
}

# Detailed dimension
resource "aws_cloudwatch_metric_alarm" "detailed_level" {
  dimensions = {
    Service   = "OrderService"
    Component = "PaymentProcessor"
    Operation = "CreditCardCharge"
  }
}
```

## Metric Math

### 1. Basic Calculations
```hcl
resource "aws_cloudwatch_dashboard" "math_example" {
  dashboard_name = "metric-math"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890"],
            ["AWS/EC2", "MemoryUtilization", "InstanceId", "i-1234567890"],
            [{
              expression = "m1 + m2",
              label = "Total Utilization",
              id = "e1"
            }]
          ]
          period = 300
        }
      }
    ]
  })
}
```

### 2. Advanced Functions
```hcl
resource "aws_cloudwatch_dashboard" "advanced_math" {
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            [{
              expression = "RATE(METRICS())",
              label = "Rate of Change"
            }],
            [{
              expression = "ANOMALY_DETECTION_BAND(m1, 2)",
              label = "Anomaly Band"
            }]
          ]
        }
      }
    ]
  })
}
```

## Statistics and Periods

### 1. Available Statistics
- Average
- Sum
- Minimum
- Maximum
- Sample Count
- Percentiles (p90, p95, p99)

### 2. Period Configuration
```hcl
resource "aws_cloudwatch_metric_alarm" "period_example" {
  period             = "60"    # 1-minute periods
  evaluation_periods = "3"     # 3 periods
  datapoints_to_alarm = "2"    # Alert if 2 out of 3 periods exceed threshold
  
  statistic          = "Average"
  extended_statistic = "p99"   # For percentile statistics
}
```

## Best Practices

### 1. Metric Design
- Use consistent naming conventions
- Choose appropriate resolution
- Implement proper dimensions
- Consider cost implications

### 2. Dimension Strategy
- Plan dimension hierarchy
- Limit dimension combinations
- Use meaningful dimension names
- Consider query patterns

### 3. Performance Optimization
- Use appropriate periods
- Implement metric aggregation
- Configure proper retention
- Monitor metric quotas

## Common Use Cases

### 1. Application Monitoring
```hcl
resource "aws_cloudwatch_metric_alarm" "api_monitoring" {
  alarm_name          = "api-health"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  threshold          = "1"
  
  metric_query {
    id          = "e1"
    expression  = "m1 + m2"
    label       = "Error Rate"
    return_data = "true"
  }
  
  metric_query {
    id = "m1"
    metric {
      metric_name = "4XXError"
      namespace   = "AWS/ApiGateway"
      period     = "300"
      stat       = "Sum"
      dimensions = {
        ApiName = var.api_name
      }
    }
  }
  
  metric_query {
    id = "m2"
    metric {
      metric_name = "5XXError"
      namespace   = "AWS/ApiGateway"
      period     = "300"
      stat       = "Sum"
      dimensions = {
        ApiName = var.api_name
      }
    }
  }
}
```

### 2. Infrastructure Monitoring
```hcl
resource "aws_cloudwatch_metric_alarm" "infrastructure" {
  alarm_name          = "cluster-health"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "HealthyHostCount"
  namespace          = "AWS/ApplicationELB"
  period            = "300"
  statistic         = "Average"
  threshold         = "2"
  
  dimensions = {
    LoadBalancer = aws_lb.example.name
    TargetGroup  = aws_lb_target_group.example.name
  }
}
```

### 3. Business Metrics
```hcl
resource "aws_cloudwatch_metric_alarm" "business" {
  alarm_name          = "order-volume"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name        = "OrderCount"
  namespace          = "Business/Orders"
  period            = "3600"  # 1-hour periods
  statistic         = "Sum"
  threshold         = "100"
  
  dimensions = {
    Region      = var.aws_region
    ProductLine = "Premium"
  }
}
```

## Additional Resources

- [CloudWatch Metrics Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html)
- [Metric Math Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/using-metric-math.html)
- [Dimensions Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html#Dimension)
- [Statistics Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html#Statistic) 