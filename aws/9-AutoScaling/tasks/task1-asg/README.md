# Task 1: Auto Scaling Group Implementation

This task guides you through creating and configuring an Auto Scaling Group (ASG) with advanced features using Terraform.

## Prerequisites

- AWS Account with appropriate permissions
- Terraform installed (v1.0.0+)
- AWS CLI configured
- Completed VPC and EC2 modules
- Application Load Balancer (if using ASG with ALB)
- EC2 Launch Template or Launch Configuration

## Task Objectives

1. Create an Auto Scaling Group
2. Configure Launch Templates
3. Set up Scaling Policies
4. Implement Instance Refresh
5. Configure Lifecycle Hooks
6. Set up CloudWatch Alarms
7. Integrate with Load Balancers

## Implementation Steps

### 1. Launch Template Configuration
```hcl
resource "aws_launch_template" "app" {
  name_prefix   = "app-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [var.security_group_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF
  )

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-server"
    }
  }
}
```

### 2. Auto Scaling Group Setup
```hcl
resource "aws_autoscaling_group" "app" {
  name                = "app-asg"
  desired_capacity    = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  target_group_arns  = [var.target_group_arn]
  vpc_zone_identifier = var.subnet_ids
  health_check_type  = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "app-server"
    propagate_at_launch = true
  }
}
```

### 3. Scaling Policies

#### Target Tracking Policy
```hcl
resource "aws_autoscaling_policy" "target_tracking_policy" {
  name                   = "target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type           = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
```

#### Step Scaling Policy
```hcl
resource "aws_autoscaling_policy" "step_policy" {
  name                   = "step-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type           = "StepScaling"
  adjustment_type       = "ChangeInCapacity"

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

### 4. Lifecycle Hooks
```hcl
resource "aws_autoscaling_lifecycle_hook" "termination_hook" {
  name                   = "termination-hook"
  autoscaling_group_name = aws_autoscaling_group.app.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  default_result        = "CONTINUE"
  heartbeat_timeout     = 300

  notification_target_arn = var.sns_topic_arn
  role_arn               = var.lifecycle_hook_role_arn
}
```

### 5. CloudWatch Alarms
```hcl
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period            = "300"
  statistic         = "Average"
  threshold         = "80"
  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.step_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}
```

## Validation Steps

1. Verify ASG Creation
```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-name app-asg
```

2. Test Scaling Policies
```bash
# Generate load to trigger scaling
stress-ng --cpu 8 --timeout 300s

# Monitor scaling activities
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name app-asg
```

3. Check Instance Health
```bash
aws autoscaling describe-auto-scaling-instances \
  --filters Name=auto-scaling-group-name,Values=app-asg
```

4. Test Instance Refresh
```bash
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name app-asg \
  --preferences MinHealthyPercentage=50
```

## Common Issues and Solutions

1. Launch Template Issues
- Problem: Instances fail to launch
- Solution:
  - Verify AMI availability
  - Check security group rules
  - Validate IAM instance profile

2. Scaling Policy Problems
- Problem: ASG not scaling as expected
- Solution:
  - Review CloudWatch metrics
  - Check scaling policy thresholds
  - Verify target tracking metrics

3. Health Check Failures
- Problem: Instances marked unhealthy
- Solution:
  - Check application health
  - Verify security group rules
  - Review health check grace period

4. Instance Refresh Issues
- Problem: Refresh process stuck
- Solution:
  - Check minimum healthy percentage
  - Verify capacity constraints
  - Review instance termination policies

## Best Practices

1. Scaling Configuration
- Use target tracking policies for predictable workloads
- Implement step scaling for more granular control
- Set appropriate cooldown periods

2. Health Checks
- Use ELB health checks when possible
- Set appropriate grace periods
- Implement detailed application health checks

3. Instance Management
- Use Launch Templates instead of Launch Configurations
- Implement proper instance termination policies
- Configure instance refresh for updates

4. Monitoring and Alerts
- Set up CloudWatch alarms for key metrics
- Monitor scaling activities
- Implement proper logging and notification

## Additional Resources

- [ASG Documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html)
- [Launch Templates](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html)
- [Scaling Policies](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-simple-step.html)
- [Instance Refresh](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-instance-refresh.html) 