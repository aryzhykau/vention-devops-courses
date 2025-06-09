# Configure AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Random string for unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "monitoring-vpc"
  }
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "monitoring-public-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "monitoring-igw"
  }
}

# Create route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "monitoring-public-rt"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create security group
resource "aws_security_group" "monitoring" {
  name        = "monitoring-sg"
  description = "Security group for monitoring instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # In production, restrict to your IP
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-sg"
  }
}

# Create IAM role
resource "aws_iam_role" "monitoring" {
  name = "monitoring-role-${random_string.suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM policy
resource "aws_iam_role_policy" "monitoring" {
  name = "monitoring-policy"
  role = aws_iam_role.monitoring.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.monitoring.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.monitoring.name
}

# Create instance profile
resource "aws_iam_instance_profile" "monitoring" {
  name = "monitoring-profile-${random_string.suffix.result}"
  role = aws_iam_role.monitoring.name
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "monitoring" {
  name              = "/aws/ec2/monitoring"
  retention_in_days = 30
}

# Create CloudWatch agent configuration
locals {
  cloudwatch_config = jsonencode({
    agent = {
      metrics_collection_interval = 60
      run_as_user               = "root"
    }
    metrics = {
      namespace = "Custom/EC2"
      metrics_collected = {
        cpu = {
          measurement = [
            "cpu_usage_idle",
            "cpu_usage_iowait",
            "cpu_usage_user",
            "cpu_usage_system"
          ]
          metrics_collection_interval = 60
          totalcpu                   = false
        }
        disk = {
          measurement = [
            "used_percent",
            "inodes_free"
          ]
          metrics_collection_interval = 60
          resources                  = ["*"]
        }
        diskio = {
          measurement = [
            "io_time",
            "write_bytes",
            "read_bytes",
            "writes",
            "reads"
          ]
          metrics_collection_interval = 60
          resources                  = ["*"]
        }
        mem = {
          measurement = [
            "mem_used_percent"
          ]
          metrics_collection_interval = 60
        }
        netstat = {
          measurement = [
            "tcp_established",
            "tcp_time_wait"
          ]
          metrics_collection_interval = 60
        }
        swap = {
          measurement = [
            "swap_used_percent"
          ]
          metrics_collection_interval = 60
        }
      }
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path = "/var/log/messages"
              log_group_name = "/aws/ec2/monitoring"
              log_stream_name = "{instance_id}"
              timestamp_format = "%b %d %H:%M:%S"
            }
          ]
        }
      }
    }
  })
}

# Create SSM parameter for CloudWatch agent config
resource "aws_ssm_parameter" "cloudwatch_config" {
  name  = "/cloudwatch-agent/config"
  type  = "String"
  value = local.cloudwatch_config
}

# Create launch template
resource "aws_launch_template" "monitoring" {
  name_prefix   = "monitoring-template"
  image_id      = "ami-0735c191cf914754d"  # Amazon Linux 2
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.monitoring.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.monitoring.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-cloudwatch-agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/cloudwatch-agent/config
              systemctl start amazon-cloudwatch-agent
              systemctl enable amazon-cloudwatch-agent
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "monitoring-instance"
    }
  }

  monitoring {
    enabled = true
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "monitoring" {
  name                = "monitoring-asg-${random_string.suffix.result}"
  desired_capacity    = 1
  max_size           = 1
  min_size           = 1
  target_group_arns  = []
  vpc_zone_identifier = [aws_subnet.public.id]
  health_check_type  = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.monitoring.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "monitoring-instance"
    propagate_at_launch = true
  }
}

# Create CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EC2 CPU utilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.monitoring.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name          = "high-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "Custom/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EC2 memory utilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.monitoring.name
  }
}

resource "aws_cloudwatch_metric_alarm" "disk" {
  alarm_name          = "high-disk-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "disk_used_percent"
  namespace           = "Custom/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EC2 disk utilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.monitoring.name
  }
}

# Create CloudWatch dashboard
resource "aws_cloudwatch_dashboard" "monitoring" {
  dashboard_name = "ec2-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", aws_autoscaling_group.monitoring.name]
          ]
          period = 300
          stat   = "Average"
          region = "us-west-2"
          title  = "CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["Custom/EC2", "mem_used_percent", "AutoScalingGroupName", aws_autoscaling_group.monitoring.name]
          ]
          period = 300
          stat   = "Average"
          region = "us-west-2"
          title  = "Memory Utilization"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["Custom/EC2", "disk_used_percent", "AutoScalingGroupName", aws_autoscaling_group.monitoring.name]
          ]
          period = 300
          stat   = "Average"
          region = "us-west-2"
          title  = "Disk Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["Custom/EC2", "tcp_established", "AutoScalingGroupName", aws_autoscaling_group.monitoring.name]
          ]
          period = 300
          stat   = "Average"
          region = "us-west-2"
          title  = "TCP Connections"
        }
      }
    ]
  })
}

# Outputs
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.monitoring.name
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.monitoring.name
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#dashboards:name=${aws_cloudwatch_dashboard.monitoring.dashboard_name}"
} 