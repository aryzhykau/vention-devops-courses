# AWS Auto Scaling Policies Guide

This document provides detailed information about different types of scaling policies available in AWS Auto Scaling and how to implement them using Terraform.

## Types of Scaling Policies

1. Target Tracking Scaling
2. Step Scaling
3. Simple Scaling
4. Predictive Scaling
5. Scheduled Scaling

## 1. Target Tracking Scaling

Target tracking scaling policies automatically adjust the size of your Auto Scaling group based on a target value for a specific metric.

### Implementation
```hcl
resource "aws_autoscaling_policy" "target_tracking" {
  name                   = "target-tracking-policy"
  policy_type           = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.example.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
```

### Available Predefined Metrics
- ASGAverageCPUUtilization
- ASGAverageNetworkIn
- ASGAverageNetworkOut
- ALBRequestCountPerTarget

### Custom Metrics Example
```hcl
resource "aws_autoscaling_policy" "custom_metric" {
  name                   = "custom-metric-policy"
  policy_type           = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.example.name

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "AutoScalingGroupName"
        value = aws_autoscaling_group.example.name
      }
      metric_name = "MyCustomMetric"
      namespace   = "MyNamespace"
      statistic   = "Average"
    }
    target_value = 100.0
  }
}
```

## 2. Step Scaling

Step scaling policies allow you to scale based on a metric using a set of scaling adjustments, known as step adjustments.

### Implementation
```hcl
resource "aws_autoscaling_policy" "step" {
  name                   = "step-scaling-policy"
  policy_type           = "StepScaling"
  autoscaling_group_name = aws_autoscaling_group.example.name
  adjustment_type       = "ChangeInCapacity"
  metric_aggregation_type = "Average"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 20
  }

  step_adjustment {
    scaling_adjustment          = 2
    metric_interval_lower_bound = 20
  }
}
```

### CloudWatch Alarm Integration
```hcl
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period            = "300"
  statistic         = "Average"
  threshold         = "80"
  alarm_actions     = [aws_autoscaling_policy.step.arn]
}
```

## 3. Simple Scaling

Simple scaling policies allow you to scale based on a single scaling adjustment.

### Implementation
```hcl
resource "aws_autoscaling_policy" "simple" {
  name                   = "simple-scaling-policy"
  scaling_adjustment     = 1
  adjustment_type       = "ChangeInCapacity"
  cooldown             = 300
  autoscaling_group_name = aws_autoscaling_group.example.name
}
```

## 4. Predictive Scaling

Predictive scaling uses machine learning to schedule scaling actions based on predicted demand.

### Implementation
```hcl
resource "aws_autoscaling_policy" "predictive" {
  name                   = "predictive-scaling-policy"
  policy_type           = "PredictiveScaling"
  autoscaling_group_name = aws_autoscaling_group.example.name

  predictive_scaling_configuration {
    metric_specification {
      target_value = 10.0
      predefined_load_metric_specification {
        predefined_metric_type = "ASGTotalCPUUtilization"
        resource_label        = "app/my-alb/778d41231b141a0f/targetgroup/my-alb-target-group/943f017f100becff"
      }
      predefined_scaling_metric_specification {
        predefined_metric_type = "ASGTotalCPUUtilization"
        resource_label        = "app/my-alb/778d41231b141a0f/targetgroup/my-alb-target-group/943f017f100becff"
      }
    }
    mode                          = "ForecastAndScale"
    scheduling_buffer_time        = 300
    max_capacity_breach_behavior = "HonorMaxCapacity"
    max_capacity_buffer         = 10
  }
}
```

## 5. Scheduled Scaling

Scheduled scaling allows you to scale your application in response to predictable load changes.

### Implementation
```hcl
resource "aws_autoscaling_schedule" "scale_up" {
  scheduled_action_name  = "scale-up"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 4
  recurrence           = "0 9 * * MON-FRI"
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_down" {
  scheduled_action_name  = "scale-down"
  min_size              = 1
  max_size              = 4
  desired_capacity      = 1
  recurrence           = "0 17 * * MON-FRI"
  autoscaling_group_name = aws_autoscaling_group.example.name
}
```

## Best Practices

### 1. Policy Selection
- Use target tracking for stable, predictable workloads
- Use step scaling for more granular control
- Use predictive scaling for recurring patterns
- Use scheduled scaling for known time-based patterns

### 2. Metric Selection
- Choose metrics that reflect application performance
- Use custom metrics when necessary
- Consider multiple metrics for complex scenarios
- Monitor metric reliability

### 3. Scaling Configuration
- Set appropriate cooldown periods
- Configure proper warm-up times
- Use gradual scaling adjustments
- Implement proper monitoring

### 4. Testing and Validation
- Test scaling policies in non-production
- Validate metric thresholds
- Monitor scaling activities
- Review scaling history

## Troubleshooting

### Common Issues
1. Scaling Not Triggered
   - Check metric data
   - Verify alarm configuration
   - Review policy settings
   - Check IAM permissions

2. Unexpected Scaling
   - Review cooldown periods
   - Check metric aggregation
   - Verify threshold values
   - Monitor concurrent policies

3. Performance Issues
   - Review warm-up times
   - Check instance health
   - Monitor application metrics
   - Validate capacity settings

## Monitoring and Maintenance

### CloudWatch Integration
```hcl
resource "aws_cloudwatch_dashboard" "scaling" {
  dashboard_name = "scaling-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity"],
            ["AWS/AutoScaling", "GroupInServiceInstances"],
            ["AWS/EC2", "CPUUtilization"]
          ]
          period = 300
          region = var.aws_region
          title  = "Auto Scaling Metrics"
        }
      }
    ]
  })
}
```

### Logging and Notifications
```hcl
resource "aws_sns_topic" "scaling_notifications" {
  name = "scaling-notifications"
}

resource "aws_autoscaling_notification" "notifications" {
  group_names = [aws_autoscaling_group.example.name]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
  topic_arn = aws_sns_topic.scaling_notifications.arn
}
``` 