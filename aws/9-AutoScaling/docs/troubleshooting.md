# AWS Auto Scaling Troubleshooting Guide

This guide provides solutions for common issues encountered with AWS Auto Scaling Groups and their components.

## Common Issues and Solutions

### 1. Launch Template/Instance Launch Issues

#### Problem: Instances Fail to Launch
```
Error: "Your requested instance type is not supported in your requested Availability Zone"
```

**Solutions:**
1. Check instance type availability:
```bash
aws ec2 describe-instance-type-offerings \
  --location-type availability-zone \
  --filters Name=location,Values=us-west-2a
```

2. Verify AMI availability:
```bash
aws ec2 describe-images --image-ids ami-12345678
```

3. Check security group configuration:
```bash
aws ec2 describe-security-groups --group-ids sg-12345678
```

#### Problem: Insufficient Capacity
```
Error: "We currently do not have sufficient instance capacity in the Availability Zone you requested"
```

**Solutions:**
1. Use multiple instance types:
```hcl
resource "aws_autoscaling_group" "example" {
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.example.id
        version           = "$Latest"
      }
      override {
        instance_type = "t3.micro"
      }
      override {
        instance_type = "t3a.micro"
      }
    }
  }
}
```

2. Use multiple Availability Zones:
```hcl
resource "aws_autoscaling_group" "example" {
  vpc_zone_identifier = [
    aws_subnet.az1.id,
    aws_subnet.az2.id,
    aws_subnet.az3.id
  ]
}
```

### 2. Scaling Policy Issues

#### Problem: No Scaling Actions Triggered
```
No scaling activities in CloudWatch logs despite metric threshold breach
```

**Solutions:**
1. Check CloudWatch Alarm configuration:
```hcl
resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name          = "cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period            = "300"
  statistic         = "Average"
  threshold         = "80"
  alarm_actions     = [aws_autoscaling_policy.example.arn]
}
```

2. Verify IAM permissions:
```hcl
data "aws_iam_policy_document" "asg" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:ExecutePolicy",
      "cloudwatch:PutMetricAlarm"
    ]
    resources = ["*"]
  }
}
```

3. Check cooldown periods:
```hcl
resource "aws_autoscaling_policy" "example" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  cooldown             = 300
  autoscaling_group_name = aws_autoscaling_group.example.name
}
```

### 3. Health Check Issues

#### Problem: Instances Marked Unhealthy
```
Instances failing ELB health checks
```

**Solutions:**
1. Adjust health check grace period:
```hcl
resource "aws_autoscaling_group" "example" {
  health_check_type         = "ELB"
  health_check_grace_period = 300
}
```

2. Verify security group rules:
```hcl
resource "aws_security_group_rule" "health_check" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.example.id
}
```

3. Check instance logs:
```bash
aws ec2 get-console-output --instance-id i-1234567890abcdef0
```

### 4. Load Balancer Integration Issues

#### Problem: Targets Not Registered
```
Instances not appearing in target group
```

**Solutions:**
1. Verify target group configuration:
```hcl
resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.example.name
  lb_target_group_arn   = aws_lb_target_group.example.arn
}
```

2. Check target group health check settings:
```hcl
resource "aws_lb_target_group" "example" {
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval           = 30
    path               = "/health"
    port               = "traffic-port"
    timeout            = 5
    unhealthy_threshold = 2
  }
}
```

## Diagnostic Tools and Commands

### 1. CloudWatch Logs

#### View Scaling Activities
```bash
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name my-asg

aws cloudwatch get-metric-statistics \
  --namespace AWS/AutoScaling \
  --metric-name GroupDesiredCapacity \
  --dimensions Name=AutoScalingGroupName,Value=my-asg \
  --start-time $(date -d '1 hour ago' -u +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 300 \
  --statistics Average
```

### 2. Instance Health Status

#### Check Instance Health
```bash
aws autoscaling describe-auto-scaling-instances \
  --instance-ids i-1234567890abcdef0

aws elb describe-instance-health \
  --load-balancer-name my-elb \
  --instances i-1234567890abcdef0
```

### 3. Configuration Validation

#### Verify Launch Template
```bash
aws ec2 describe-launch-template-versions \
  --launch-template-id lt-1234567890abcdef0

aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names my-asg \
  --query 'AutoScalingGroups[].LaunchTemplate'
```

## Prevention and Best Practices

### 1. Monitoring Setup

#### CloudWatch Dashboard
```hcl
resource "aws_cloudwatch_dashboard" "asg" {
  dashboard_name = "asg-monitoring"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity"],
            ["AWS/AutoScaling", "GroupInServiceInstances"],
            ["AWS/EC2", "CPUUtilization"],
            ["AWS/EC2", "StatusCheckFailed"]
          ]
          period = 300
          region = var.aws_region
        }
      }
    ]
  })
}
```

### 2. Alerting Configuration

#### SNS Notifications
```hcl
resource "aws_autoscaling_notification" "asg_notifications" {
  group_names = [aws_autoscaling_group.example.name]
  
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  topic_arn = aws_sns_topic.asg_updates.arn
}
```

### 3. Backup and Recovery

#### Instance Refresh
```hcl
resource "aws_autoscaling_group" "example" {
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      instance_warmup = 300
    }
    triggers = ["tag"]
  }
}
```

## Additional Resources

1. AWS Documentation
   - [Auto Scaling Troubleshooting Guide](https://docs.aws.amazon.com/autoscaling/ec2/userguide/CHAP_Troubleshooting.html)
   - [CloudWatch Metrics Reference](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ec2-metricscollected.html)

2. Terraform Resources
   - [AWS Auto Scaling Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)
   - [Launch Template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template)

3. Monitoring Tools
   - CloudWatch
   - AWS Systems Manager
   - AWS Config 