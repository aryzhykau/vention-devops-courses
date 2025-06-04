# AWS EC2 Best Practices

## Security Best Practices

### 1. Network Security
```hcl
# Security Group Configuration
resource "aws_security_group" "web" {
  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from specific sources only
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["TRUSTED_IP_RANGE"]
  }

  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["TRUSTED_IP_RANGE"]
  }

  # Restrict SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["MANAGEMENT_IP_RANGE"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Best Practices:
1. Use security groups as the primary layer of defense
2. Follow the principle of least privilege
3. Regularly audit and update security group rules
4. Use NACLs for additional network security
5. Implement proper network segmentation

### 2. Access Management
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Environment": "Production"
        }
      }
    }
  ]
}
```

Best Practices:
1. Use IAM roles instead of access keys
2. Implement role-based access control
3. Regularly rotate credentials
4. Monitor and audit access patterns
5. Use AWS Organizations for multi-account management

### 3. Data Security
```hcl
# EBS Volume Encryption
resource "aws_ebs_volume" "data" {
  availability_zone = "us-west-2a"
  size             = 100
  encrypted        = true
  kms_key_id       = aws_kms_key.ebs.arn

  tags = {
    Name = "encrypted-volume"
  }
}
```

Best Practices:
1. Enable encryption at rest
2. Use AWS KMS for key management
3. Implement proper backup strategies
4. Secure data in transit
5. Regular security assessments

## Performance Best Practices

### 1. Instance Selection
```hcl
# Instance Configuration
resource "aws_instance" "web" {
  ami           = "ami-0735c191cf914754d"
  instance_type = "m5.large"

  ebs_optimized = true
  monitoring    = true

  root_block_device {
    volume_type = "gp3"
    iops        = 3000
    throughput  = 125
  }

  tags = {
    Name = "web-server"
  }
}
```

Best Practices:
1. Choose appropriate instance types
2. Enable EBS optimization
3. Use enhanced networking
4. Monitor and adjust based on metrics
5. Implement auto scaling

### 2. Storage Optimization
```hcl
# Storage Configuration
resource "aws_ebs_volume" "data" {
  availability_zone = "us-west-2a"
  size             = 100
  type             = "gp3"
  iops             = 3000
  throughput       = 125

  tags = {
    Name = "optimized-volume"
  }
}
```

Best Practices:
1. Use appropriate storage types
2. Monitor IOPS and throughput
3. Implement proper RAID configurations
4. Regular volume maintenance
5. Use instance store for temporary data

## High Availability Best Practices

### 1. Multi-AZ Deployment
```hcl
# Auto Scaling Group Configuration
resource "aws_autoscaling_group" "web" {
  name                = "web-asg"
  desired_capacity    = 3
  max_size           = 6
  min_size           = 2
  target_group_arns  = [aws_lb_target_group.web.arn]
  vpc_zone_identifier = aws_subnet.private[*].id

  health_check_type          = "ELB"
  health_check_grace_period  = 300

  tag {
    key                 = "Name"
    value               = "web-server"
    propagate_at_launch = true
  }
}
```

Best Practices:
1. Deploy across multiple AZs
2. Use Auto Scaling Groups
3. Implement proper health checks
4. Configure appropriate scaling policies
5. Regular failover testing

### 2. Load Balancing
```hcl
# Application Load Balancer Configuration
resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = aws_subnet.public[*].id

  enable_deletion_protection = true
  enable_http2             = true

  tags = {
    Name = "web-alb"
  }
}
```

Best Practices:
1. Use appropriate load balancer type
2. Configure health checks
3. Implement SSL/TLS termination
4. Enable access logs
5. Monitor load balancer metrics

## Cost Optimization Best Practices

### 1. Instance Cost Management
```hcl
# Spot Instance Configuration
resource "aws_spot_instance_request" "worker" {
  ami           = "ami-0735c191cf914754d"
  instance_type = "c5.large"

  spot_price           = "0.05"
  wait_for_fulfillment = true

  tags = {
    Name = "spot-worker"
  }
}
```

Best Practices:
1. Use appropriate pricing models
2. Implement auto scaling
3. Right-size instances
4. Use Spot instances where appropriate
5. Regular cost analysis

### 2. Storage Cost Optimization
```hcl
# Lifecycle Policy Configuration
resource "aws_ebs_volume" "data" {
  availability_zone = "us-west-2a"
  size             = 100
  type             = "gp3"

  tags = {
    Name = "cost-optimized-volume"
  }
}

resource "aws_dlm_lifecycle_policy" "ebs_policy" {
  description        = "EBS snapshot policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "2 weeks of daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times        = ["23:45"]
      }

      retain_rule {
        count = 14
      }
    }

    target_tags = {
      Snapshot = "true"
    }
  }
}
```

Best Practices:
1. Use appropriate storage types
2. Implement lifecycle policies
3. Clean up unused resources
4. Monitor storage usage
5. Use S3 for infrequently accessed data

## Monitoring Best Practices

### 1. CloudWatch Configuration
```hcl
# CloudWatch Dashboard Configuration
resource "aws_cloudwatch_dashboard" "ec2" {
  dashboard_name = "ec2-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization"],
            [".", "DiskReadOps"],
            [".", "DiskWriteOps"],
            [".", "NetworkIn"],
            [".", "NetworkOut"]
          ]
          period = 300
          stat   = "Average"
          region = "us-west-2"
        }
      }
    ]
  })
}
```

Best Practices:
1. Enable detailed monitoring
2. Set up appropriate alarms
3. Use custom metrics
4. Implement log aggregation
5. Regular metric analysis

### 2. Alerting
```hcl
# CloudWatch Alarm Configuration
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EC2 CPU utilization"

  alarm_actions = [aws_sns_topic.alerts.arn]
}
```

Best Practices:
1. Set appropriate thresholds
2. Configure multiple notification channels
3. Implement escalation procedures
4. Regular alarm review
5. Document response procedures

## Operational Excellence

### 1. Automation
```hcl
# Systems Manager Automation
resource "aws_ssm_maintenance_window" "window" {
  name     = "maintenance-window"
  schedule = "cron(0 2 ? * SUN *)"
  duration = "3"
}

resource "aws_ssm_maintenance_window_target" "target" {
  window_id = aws_ssm_maintenance_window.window.id
  
  targets {
    key    = "tag:Patch Group"
    values = ["production"]
  }
}
```

Best Practices:
1. Use Infrastructure as Code
2. Implement automated patching
3. Regular backup automation
4. Use Systems Manager for management
5. Document all procedures

### 2. Documentation
Best Practices:
1. Maintain up-to-date documentation
2. Document all configurations
3. Create runbooks for common tasks
4. Implement change management
5. Regular documentation review

## Compliance Best Practices

### 1. Audit Configuration
```hcl
# AWS Config Rule
resource "aws_config_config_rule" "ec2_encrypted_volumes" {
  name = "ec2-encrypted-volumes"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  scope {
    compliance_resource_types = ["AWS::EC2::Volume"]
  }
}
```

Best Practices:
1. Enable AWS Config
2. Implement compliance rules
3. Regular compliance audits
4. Document compliance requirements
5. Monitor compliance status

### 2. Logging
```hcl
# CloudTrail Configuration
resource "aws_cloudtrail" "main" {
  name                          = "ec2-audit-trail"
  s3_bucket_name               = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
```

Best Practices:
1. Enable CloudTrail
2. Configure log retention
3. Implement log analysis
4. Regular security assessments
5. Document audit procedures 