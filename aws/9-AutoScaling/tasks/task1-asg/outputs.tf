# Launch Template Outputs
output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.app.id
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = aws_launch_template.app.arn
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.app.latest_version
}

# Auto Scaling Group Outputs
output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.id
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "autoscaling_group_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.min_size
}

output "autoscaling_group_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.max_size
}

output "autoscaling_group_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.desired_capacity
}

# Scaling Policy Outputs
output "scaling_policies" {
  description = "Map of scaling policies and their ARNs"
  value = {
    cpu_policy = {
      name = aws_autoscaling_policy.cpu_policy.name
      arn  = aws_autoscaling_policy.cpu_policy.arn
    }
    request_count_policy = length(var.target_group_arns) > 0 ? {
      name = aws_autoscaling_policy.request_count_policy[0].name
      arn  = aws_autoscaling_policy.request_count_policy[0].arn
    } : null
    cpu_high = {
      name = aws_autoscaling_policy.cpu_high.name
      arn  = aws_autoscaling_policy.cpu_high.arn
    }
    cpu_low = {
      name = aws_autoscaling_policy.cpu_low.name
      arn  = aws_autoscaling_policy.cpu_low.arn
    }
  }
}

# Lifecycle Hook Outputs
output "lifecycle_hooks" {
  description = "Map of lifecycle hooks and their ARNs"
  value = {
    launch = {
      name = aws_autoscaling_lifecycle_hook.launch_hook.name
      arn  = aws_autoscaling_lifecycle_hook.launch_hook.id
    }
    terminate = {
      name = aws_autoscaling_lifecycle_hook.terminate_hook.name
      arn  = aws_autoscaling_lifecycle_hook.terminate_hook.id
    }
  }
}

# CloudWatch Alarm Outputs
output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarms and their ARNs"
  value = {
    cpu_high = {
      name = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
      arn  = aws_cloudwatch_metric_alarm.cpu_high.arn
    }
    cpu_low = {
      name = aws_cloudwatch_metric_alarm.cpu_low.alarm_name
      arn  = aws_cloudwatch_metric_alarm.cpu_low.arn
    }
  }
}

# Scheduled Actions Outputs
output "scheduled_actions" {
  description = "Map of scheduled actions and their ARNs"
  value = var.enable_scheduled_actions ? {
    scale_up = {
      name = aws_autoscaling_schedule.scale_up[0].scheduled_action_name
      arn  = aws_autoscaling_schedule.scale_up[0].arn
    }
    scale_down = {
      name = aws_autoscaling_schedule.scale_down[0].scheduled_action_name
      arn  = aws_autoscaling_schedule.scale_down[0].arn
    }
  } : null
} 