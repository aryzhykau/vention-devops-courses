# VPC Best Practices

## Network Design

### 1. IP Address Planning
- Use appropriate CIDR block size for future growth
- Plan subnet sizes based on workload requirements
- Reserve IP ranges for future expansion
- Document IP allocation strategy
- Consider IPv6 requirements

### 2. Subnet Design
- Use multiple Availability Zones
- Separate public and private subnets
- Size subnets appropriately
- Consider placement groups requirements
- Plan for specialized workloads

### 3. Availability Zones
- Deploy across multiple AZs
- Balance resources across AZs
- Consider AZ-specific services
- Plan for AZ failure
- Implement automatic failover

## Security

### 1. Network Access Control
```hcl
# Example Security Group Configuration
resource "aws_security_group" "web" {
  name        = "web-server"
  description = "Web Server Security Group"
  vpc_id      = aws_vpc.main.id

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
}
```

### 2. Security Layers
- Implement defense in depth
- Use security groups and NACLs
- Enable VPC flow logs
- Monitor network traffic
- Implement IDS/IPS solutions

### 3. Network Isolation
- Use private subnets for backend services
- Implement network segmentation
- Use VPC endpoints for AWS services
- Control cross-VPC access
- Implement least privilege access

## Connectivity

### 1. Internet Access
- Use NAT Gateway for private subnets
- Implement redundant NAT Gateways
- Monitor NAT Gateway capacity
- Consider NAT Instance alternatives
- Plan for internet gateway redundancy

### 2. VPC Connectivity
```hcl
# Example VPC Peering Configuration
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id = aws_vpc.peer.id
  vpc_id      = aws_vpc.main.id
  auto_accept = true

  tags = {
    Name = "VPC Peering between main and peer"
  }
}
```

### 3. AWS Service Access
- Use VPC endpoints where possible
- Implement endpoint policies
- Monitor endpoint usage
- Consider PrivateLink for services
- Plan endpoint capacity

## Monitoring and Operations

### 1. Flow Logs
- Enable flow logs for security
- Configure CloudWatch integration
- Set up log retention
- Monitor network patterns
- Implement automated analysis

### 2. Monitoring
```hcl
# Example CloudWatch Metric Alarm
resource "aws_cloudwatch_metric_alarm" "nat_gateway" {
  alarm_name          = "nat-gateway-bytes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BytesOutToDestination"
  namespace           = "AWS/NATGateway"
  period             = "300"
  statistic          = "Average"
  threshold          = "5000000"
  alarm_description  = "NAT Gateway bytes threshold exceeded"
}
```

### 3. Troubleshooting
- Use VPC reachability analyzer
- Implement proper tagging
- Document network architecture
- Maintain network diagrams
- Create runbooks for common issues

## Cost Optimization

### 1. Resource Planning
- Right-size NAT Gateways
- Optimize VPC endpoint usage
- Monitor data transfer costs
- Use cost allocation tags
- Implement budget alerts

### 2. Traffic Management
- Optimize routing for cost
- Monitor cross-AZ traffic
- Use Direct Connect where appropriate
- Implement caching strategies
- Control egress traffic

## Disaster Recovery

### 1. Backup and Recovery
- Document VPC configurations
- Implement infrastructure as code
- Test recovery procedures
- Maintain configuration backups
- Plan for region recovery

### 2. High Availability
```hcl
# Example Multi-AZ NAT Gateway Configuration
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "NAT Gateway AZ1"
  }
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "NAT Gateway AZ2"
  }
}
```

## Implementation Guidelines

### 1. VPC Design Patterns
- Hub-and-spoke using Transit Gateway
- Isolated VPCs for security
- Shared services VPC
- Development/Testing/Production separation
- Multi-account strategy

### 2. Automation
- Use Infrastructure as Code
- Implement automated testing
- Create reusable components
- Document automation procedures
- Maintain version control

### 3. Documentation
- Network architecture diagrams
- IP address allocation
- Security group matrices
- Route table configurations
- Change management procedures 