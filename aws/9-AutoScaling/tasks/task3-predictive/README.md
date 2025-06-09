# Task 3: Predictive Scaling Implementation

This task guides you through implementing predictive scaling for your Auto Scaling Groups using machine learning forecasting.

## Prerequisites

- AWS Account with appropriate permissions
- Terraform installed (v1.0.0+)
- AWS CLI configured
- Completed Task 1 (Basic ASG)
- Historical metric data for predictions

## Task Objectives

1. Set up predictive scaling
2. Configure machine learning forecasting
3. Implement scheduled scaling
4. Set up dynamic scaling
5. Configure target tracking

## Implementation Steps

### 1. Predictive Scaling Policy
```hcl
resource "aws_autoscaling_policy" "predictive" {
  name                   = "predictive-scaling-policy"
  policy_type           = "PredictiveScaling"
  autoscaling_group_name = aws_autoscaling_group.app.name

  predictive_scaling_configuration {
    metric_specification {
      target_value = 70.0

      predefined_load_metric_specification {
        predefined_metric_type = "ASGTotalCPUUtilization"
        resource_label        = "${var.alb_arn_suffix}/${var.target_group_arn_suffix}"
      }

      predefined_scaling_metric_specification {
        predefined_metric_type = "ASGTotalCPUUtilization"
        resource_label        = "${var.alb_arn_suffix}/${var.target_group_arn_suffix}"
      }
    }

    mode                          = "ForecastAndScale"
    scheduling_buffer_time        = 300
    max_capacity_breach_behavior = "HonorMaxCapacity"
    max_capacity_buffer         = 10
  }
}
```

### 2. Dynamic Scaling Configuration
```hcl
resource "aws_autoscaling_policy" "dynamic" {
  name                   = "dynamic-scaling-policy"
  policy_type           = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
```

### 3. Scheduled Actions
```hcl
resource "aws_autoscaling_schedule" "scale_up" {
  scheduled_action_name  = "scale-up"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 4
  recurrence           = "0 9 * * MON-FRI"
  time_zone            = "UTC"
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_autoscaling_schedule" "scale_down" {
  scheduled_action_name  = "scale-down"
  min_size              = 1
  max_size              = 4
  desired_capacity      = 1
  recurrence           = "0 17 * * MON-FRI"
  time_zone            = "UTC"
  autoscaling_group_name = aws_autoscaling_group.app.name
}
```

## Validation Steps

1. Verify Predictive Scaling
```bash
# Check predictive scaling policy
aws autoscaling describe-policies \
  --auto-scaling-group-name app-asg \
  --policy-types "PredictiveScaling"

# Monitor forecasted capacity
aws autoscaling get-predictive-scaling-forecast \
  --auto-scaling-group-name app-asg \
  --policy-name predictive-scaling-policy
```

2. Monitor Scaling Activities
```bash
# View scaling activities
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name app-asg

# Check current capacity
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-name app-asg \
  --query 'AutoScalingGroups[].{CurrentSize:DesiredCapacity,MinSize:MinSize,MaxSize:MaxSize}'
```

3. Review Metrics and Forecasts
```bash
# Get metric data
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
              "Name": "AutoScalingGroupName",
              "Value": "app-asg"
            }
          ]
        },
        "Period": 300,
        "Stat": "Average"
      }
    }
  ]' \
  --start-time $(date -d '24 hours ago' -u +%FT%TZ) \
  --end-time $(date -u +%FT%TZ)
```

## Common Issues and Solutions

1. Insufficient Historical Data
- Problem: Not enough data for predictions
- Solution:
  - Collect at least 24 hours of metric data
  - Use appropriate metrics
  - Configure proper monitoring

2. Forecast Accuracy Issues
- Problem: Inaccurate predictions
- Solution:
  - Review metric selection
  - Adjust target values
  - Configure proper buffer times

3. Scaling Conflicts
- Problem: Multiple policies conflict
- Solution:
  - Review policy priorities
  - Adjust cooldown periods
  - Configure proper thresholds

## Best Practices

1. Metric Selection
- Choose appropriate metrics
- Use multiple metrics when needed
- Monitor metric reliability
- Configure proper aggregation

2. Forecast Configuration
- Set appropriate buffer times
- Configure proper modes
- Review forecast accuracy
- Adjust target values

3. Policy Management
- Review policy interactions
- Configure proper cooldowns
- Monitor scaling activities
- Implement proper logging

4. Cost Optimization
- Monitor capacity utilization
- Review scaling patterns
- Implement proper tagging
- Track cost metrics

## CloudWatch Dashboard
```hcl
resource "aws_cloudwatch_dashboard" "predictive_scaling" {
  dashboard_name = "predictive-scaling"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity"],
            ["AWS/AutoScaling", "GroupInServiceInstances"],
            ["AWS/EC2", "CPUUtilization"],
            ["AWS/AutoScaling", "PredictiveScalingForecast"]
          ]
          period = 300
          region = var.aws_region
          title  = "Predictive Scaling Metrics"
        }
      }
    ]
  })
}
```

## Monitoring and Alerts
```hcl
resource "aws_cloudwatch_metric_alarm" "forecast_accuracy" {
  alarm_name          = "forecast-accuracy"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name        = "PredictiveScalingForecastError"
  namespace          = "AWS/AutoScaling"
  period            = "3600"
  statistic         = "Average"
  threshold         = "20"
  alarm_description = "Monitor predictive scaling forecast accuracy"
  alarm_actions     = [var.sns_topic_arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}
```

## Additional Resources

- [Predictive Scaling Documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-predictive-scaling.html)
- [Machine Learning Forecasting](https://docs.aws.amazon.com/autoscaling/ec2/userguide/predictive-scaling-graphs.html)
- [Scaling Based on Metrics](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html)
- [Best Practices Guide](https://docs.aws.amazon.com/autoscaling/ec2/userguide/auto-scaling-best-practices.html) 