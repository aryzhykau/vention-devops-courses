# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Data source for current AWS region
data "aws_region" "current" {}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-${var.project_name}-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups            = var.security_group_ids
  }

  user_data = base64encode(var.user_data)

  iam_instance_profile {
    name = var.instance_profile_name
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type          = "gp3"
      delete_on_termination = true
      encrypted            = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-${var.project_name}-instance"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-${var.project_name}-volume"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                = "${var.environment}-${var.project_name}-asg"
  desired_capacity    = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  target_group_arns  = var.target_group_arns
  vpc_zone_identifier = var.subnet_ids
  health_check_type  = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = var.min_healthy_percentage
      instance_warmup       = var.instance_warmup
    }
    triggers = ["tag"]
  }

  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        Name = "${var.environment}-${var.project_name}-asg"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# Target Tracking Scaling Policy - CPU Utilization
resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "${var.environment}-${var.project_name}-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type           = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.target_cpu_value
  }
}

# Target Tracking Scaling Policy - Request Count Per Target
resource "aws_autoscaling_policy" "request_count_policy" {
  count = length(var.target_group_arns) > 0 ? 1 : 0

  name                   = "${var.environment}-${var.project_name}-request-count-policy"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type           = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label        = "${var.alb_arn_suffix}/${var.target_group_arn_suffix}"
    }
    target_value = var.target_requests_per_instance
  }
}

# Step Scaling Policy - High CPU
resource "aws_autoscaling_policy" "cpu_high" {
  name                   = "${var.environment}-${var.project_name}-cpu-high"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type           = "StepScaling"
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

# Step Scaling Policy - Low CPU
resource "aws_autoscaling_policy" "cpu_low" {
  name                   = "${var.environment}-${var.project_name}-cpu-low"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type           = "StepScaling"
  adjustment_type       = "ChangeInCapacity"
  metric_aggregation_type = "Average"

  step_adjustment {
    scaling_adjustment          = -1
    metric_interval_upper_bound = 0
    metric_interval_lower_bound = -20
  }

  step_adjustment {
    scaling_adjustment          = -2
    metric_interval_upper_bound = -20
  }
}

# Lifecycle Hook - Instance Launch
resource "aws_autoscaling_lifecycle_hook" "launch_hook" {
  name                   = "${var.environment}-${var.project_name}-launch-hook"
  autoscaling_group_name = aws_autoscaling_group.app.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  default_result        = "CONTINUE"
  heartbeat_timeout     = var.lifecycle_hook_timeout

  notification_target_arn = var.sns_topic_arn
  role_arn               = var.lifecycle_hook_role_arn
}

# Lifecycle Hook - Instance Terminate
resource "aws_autoscaling_lifecycle_hook" "terminate_hook" {
  name                   = "${var.environment}-${var.project_name}-terminate-hook"
  autoscaling_group_name = aws_autoscaling_group.app.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  default_result        = "CONTINUE"
  heartbeat_timeout     = var.lifecycle_hook_timeout

  notification_target_arn = var.sns_topic_arn
  role_arn               = var.lifecycle_hook_role_arn
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.environment}-${var.project_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period            = "300"
  statistic         = "Average"
  threshold         = var.cpu_high_threshold
  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.cpu_high.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.environment}-${var.project_name}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period            = "300"
  statistic         = "Average"
  threshold         = var.cpu_low_threshold
  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.cpu_low.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

# Schedule Actions (Optional)
resource "aws_autoscaling_schedule" "scale_up" {
  count = var.enable_scheduled_actions ? 1 : 0

  scheduled_action_name  = "${var.environment}-${var.project_name}-scale-up"
  min_size              = var.schedule_scale_up_min
  max_size              = var.schedule_scale_up_max
  desired_capacity      = var.schedule_scale_up_desired
  recurrence           = var.schedule_scale_up_recurrence
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_autoscaling_schedule" "scale_down" {
  count = var.enable_scheduled_actions ? 1 : 0

  scheduled_action_name  = "${var.environment}-${var.project_name}-scale-down"
  min_size              = var.schedule_scale_down_min
  max_size              = var.schedule_scale_down_max
  desired_capacity      = var.schedule_scale_down_desired
  recurrence           = var.schedule_scale_down_recurrence
  autoscaling_group_name = aws_autoscaling_group.app.name
} 