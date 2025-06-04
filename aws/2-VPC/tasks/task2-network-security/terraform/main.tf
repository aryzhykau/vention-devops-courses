provider "aws" {
  region = var.aws_region
}

# Network ACLs
resource "aws_network_acl" "main" {
  vpc_id = var.vpc_id

  # Allow inbound HTTP/HTTPS from anywhere
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow inbound SSH from specific IP range
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.admin_cidr
    from_port  = 22
    to_port    = 22
  }

  # Allow all outbound traffic
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-nacl"
  })
}

# Security Groups
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-web-sg"
  })
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for application servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-app-sg"
  })
}

# VPC Flow Logs
resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-flow-log"
  })
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/aws/vpc/flow-log/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_iam_role" "flow_log" {
  name = "${var.project_name}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "flow_log" {
  name = "${var.project_name}-flow-log-policy"
  role = aws_iam_role.flow_log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Traffic Mirroring
resource "aws_ec2_traffic_mirror_target" "main" {
  description          = "Traffic mirror target for ${var.project_name}"
  network_interface_id = var.monitoring_eni_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-mirror-target"
  })
}

resource "aws_ec2_traffic_mirror_filter" "main" {
  description      = "Traffic mirror filter for ${var.project_name}"
  network_services = ["amazon-dns"]

  tags = merge(var.tags, {
    Name = "${var.project_name}-mirror-filter"
  })
}

resource "aws_ec2_traffic_mirror_filter_rule" "inbound" {
  description              = "Allow inbound HTTP/HTTPS"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.main.id
  rule_number             = 1
  rule_action             = "accept"
  destination_cidr_block  = "0.0.0.0/0"
  source_cidr_block       = "0.0.0.0/0"
  protocol                = 6

  destination_port_range {
    from_port = 80
    to_port   = 443
  }
}

# Network Firewall
resource "aws_networkfirewall_firewall" "main" {
  name                = "${var.project_name}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = var.vpc_id

  subnet_mapping {
    subnet_id = var.firewall_subnet_id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-firewall"
  })
}

resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${var.project_name}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.main.arn
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_rule_group" "main" {
  capacity = 100
  name     = "${var.project_name}-rule-group"
  type     = "STATEFUL"
  rules    = <<EOF
{
  "rulesSource": {
    "statefulRules": [
      {
        "action": "PASS",
        "header": {
          "destination": "ANY",
          "destinationPort": "ANY",
          "direction": "ANY",
          "protocol": "HTTP",
          "source": "ANY",
          "sourcePort": "ANY"
        },
        "ruleOptions": {
          "keyword": "sid:1",
          "content": "GET"
        }
      }
    ]
  }
}
EOF

  tags = var.tags
}

# CloudWatch Alarms for Security Monitoring
resource "aws_cloudwatch_metric_alarm" "blocked_requests" {
  alarm_name          = "${var.project_name}-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/NetworkFirewall"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.blocked_requests_threshold
  alarm_description  = "This metric monitors blocked requests by Network Firewall"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    FirewallName = aws_networkfirewall_firewall.main.name
  }

  tags = var.tags
} 