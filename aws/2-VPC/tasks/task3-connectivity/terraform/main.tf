provider "aws" {
  region = var.aws_region
  alias  = "main"
}

provider "aws" {
  region = var.peer_region
  alias  = "peer"
}

# VPC Peering
resource "aws_vpc_peering_connection" "main" {
  provider      = aws.main
  vpc_id        = var.vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_region   = var.peer_region
  auto_accept   = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-peering"
  })
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  auto_accept              = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-peering-accepter"
  })
}

# Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  provider = aws.main
  description = "Transit Gateway for ${var.project_name}"
  
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  
  tags = merge(var.tags, {
    Name = "${var.project_name}-tgw"
  })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  provider           = aws.main
  subnet_ids         = var.tgw_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-tgw-attachment"
  })
}

# VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  provider        = aws.main
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = var.private_route_table_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-s3-endpoint"
  })
}

resource "aws_vpc_endpoint" "dynamodb" {
  provider        = aws.main
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${var.aws_region}.dynamodb"
  route_table_ids = var.private_route_table_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-dynamodb-endpoint"
  })
}

resource "aws_security_group" "endpoints" {
  provider    = aws.main
  name        = "${var.project_name}-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-endpoint-sg"
  })
}

resource "aws_vpc_endpoint" "ssm" {
  provider            = aws.main
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.endpoint_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-ssm-endpoint"
  })
}

# Site-to-Site VPN
resource "aws_customer_gateway" "main" {
  provider   = aws.main
  bgp_asn    = var.customer_bgp_asn
  ip_address = var.customer_ip
  type       = "ipsec.1"

  tags = merge(var.tags, {
    Name = "${var.project_name}-customer-gateway"
  })
}

resource "aws_vpn_gateway" "main" {
  provider = aws.main
  vpc_id   = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpn-gateway"
  })
}

resource "aws_vpn_connection" "main" {
  provider              = aws.main
  vpn_gateway_id        = aws_vpn_gateway.main.id
  customer_gateway_id   = aws_customer_gateway.main.id
  type                  = "ipsec.1"
  static_routes_only    = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpn"
  })
}

resource "aws_vpn_connection_route" "main" {
  provider               = aws.main
  destination_cidr_block = var.remote_cidr
  vpn_connection_id      = aws_vpn_connection.main.id
}

# CloudWatch Monitoring
resource "aws_cloudwatch_metric_alarm" "vpn_tunnel1_status" {
  provider            = aws.main
  alarm_name          = "${var.project_name}-vpn-tunnel1-status"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period             = "300"
  statistic          = "Average"
  threshold          = "1"
  alarm_description  = "This metric monitors VPN tunnel 1 status"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    VpnId = aws_vpn_connection.main.id
    TunnelIpAddress = aws_vpn_connection.main.tunnel1_address
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "vpn_tunnel2_status" {
  provider            = aws.main
  alarm_name          = "${var.project_name}-vpn-tunnel2-status"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period             = "300"
  statistic          = "Average"
  threshold          = "1"
  alarm_description  = "This metric monitors VPN tunnel 2 status"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    VpnId = aws_vpn_connection.main.id
    TunnelIpAddress = aws_vpn_connection.main.tunnel2_address
  }

  tags = var.tags
} 