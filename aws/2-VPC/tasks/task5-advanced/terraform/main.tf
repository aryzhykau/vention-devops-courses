provider "aws" {
  region = var.aws_region
}

# Enable IPv6 for VPC
resource "aws_vpc_ipv6_cidr_block_association" "main" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-ipv6"
  })
}

# Update Subnet Configuration for IPv6
resource "aws_subnet_ipv6_cidr_block_association" "public" {
  count             = length(var.public_subnet_ids)
  subnet_id         = var.public_subnet_ids[count.index]
  ipv6_cidr_block  = cidrsubnet(aws_vpc_ipv6_cidr_block_association.main.ipv6_cidr_block, 8, count.index)
}

resource "aws_subnet_ipv6_cidr_block_association" "private" {
  count             = length(var.private_subnet_ids)
  subnet_id         = var.private_subnet_ids[count.index]
  ipv6_cidr_block  = cidrsubnet(aws_vpc_ipv6_cidr_block_association.main.ipv6_cidr_block, 8, count.index + length(var.public_subnet_ids))
}

# Egress-Only Internet Gateway
resource "aws_egress_only_internet_gateway" "main" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-eigw"
  })
}

# Update Route Tables for IPv6
resource "aws_route" "private_ipv6_egress" {
  count                       = length(var.private_route_table_ids)
  route_table_id             = var.private_route_table_ids[count.index]
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id     = aws_egress_only_internet_gateway.main.id
}

# VPC Sharing (AWS RAM)
resource "aws_ram_resource_share" "vpc_share" {
  name                      = "${var.project_name}-vpc-share"
  allow_external_principals = false

  tags = var.tags
}

resource "aws_ram_resource_association" "subnet_share" {
  count              = length(var.shared_subnet_ids)
  resource_arn       = "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:subnet/${var.shared_subnet_ids[count.index]}"
  resource_share_arn = aws_ram_resource_share.vpc_share.arn
}

resource "aws_ram_principal_association" "account_share" {
  count              = length(var.participant_account_ids)
  principal          = var.participant_account_ids[count.index]
  resource_share_arn = aws_ram_resource_share.vpc_share.arn
}

# PrivateLink Configuration
resource "aws_vpc_endpoint_service" "service" {
  acceptance_required        = true
  network_load_balancer_arns = [var.nlb_arn]

  tags = merge(var.tags, {
    Name = "${var.project_name}-endpoint-service"
  })
}

resource "aws_vpc_endpoint_service_allowed_principal" "service" {
  count                   = length(var.allowed_principals)
  vpc_endpoint_service_id = aws_vpc_endpoint_service.service.id
  principal_arn           = var.allowed_principals[count.index]
}

# DNS Resolution (Route 53 Resolver)
resource "aws_route53_resolver_endpoint" "outbound" {
  name      = "${var.project_name}-outbound-resolver"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.resolver.id]

  dynamic "ip_address" {
    for_each = var.resolver_subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-outbound-resolver"
  })
}

resource "aws_route53_resolver_rule" "forward" {
  domain_name          = var.forward_domain
  name                 = "${var.project_name}-forward-rule"
  rule_type           = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  dynamic "target_ip" {
    for_each = var.dns_target_ips
    content {
      ip   = target_ip.value
      port = 53
    }
  }

  tags = var.tags
}

resource "aws_route53_resolver_rule_association" "forward" {
  resolver_rule_id = aws_route53_resolver_rule.forward.id
  vpc_id           = var.vpc_id
}

# Security Group for Route 53 Resolver
resource "aws_security_group" "resolver" {
  name        = "${var.project_name}-resolver-sg"
  description = "Security group for Route 53 Resolver endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-resolver-sg"
  })
}

# CloudWatch Monitoring
resource "aws_cloudwatch_metric_alarm" "endpoint_health" {
  alarm_name          = "${var.project_name}-endpoint-health"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EndpointAvailability"
  namespace           = "AWS/Route53Resolver"
  period             = "300"
  statistic          = "Average"
  threshold          = "1"
  alarm_description  = "This metric monitors Route 53 Resolver endpoint health"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    EndpointId = aws_route53_resolver_endpoint.outbound.id
  }

  tags = var.tags
}

# Data Source for Current Account ID
data "aws_caller_identity" "current" {} 