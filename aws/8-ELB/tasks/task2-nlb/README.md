# Task 2: Network Load Balancer Implementation

This task guides you through creating and configuring a Network Load Balancer (NLB) with advanced features using Terraform.

## Prerequisites

- AWS Account with appropriate permissions
- Terraform installed (v1.0.0+)
- AWS CLI configured
- Completed VPC and EC2 modules
- SSL certificate in ACM (for TLS listeners)
- Sample TCP/UDP applications running on EC2 instances

## Task Objectives

1. Create a Network Load Balancer
2. Configure TCP and UDP listeners
3. Set up TLS termination
4. Configure static IP addresses
5. Implement cross-zone load balancing
6. Set up health checks and monitoring

## Implementation Steps

### 1. Basic NLB Setup
```hcl
# Create NLB
resource "aws_lb" "network" {
  name               = "example-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids
  
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = true
  
  tags = {
    Environment = var.environment
  }
}
```

### 2. Target Groups Configuration
```hcl
# TCP Target Group
resource "aws_lb_target_group" "tcp" {
  name        = "tcp-target-group"
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    protocol            = "TCP"
    port               = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval           = 30
  }
}

# UDP Target Group
resource "aws_lb_target_group" "udp" {
  name        = "udp-target-group"
  port        = 53
  protocol    = "UDP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    protocol            = "TCP"
    port               = 53
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval           = 30
  }
}

# TLS Target Group
resource "aws_lb_target_group" "tls" {
  name        = "tls-target-group"
  port        = 443
  protocol    = "TLS"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    protocol            = "TCP"
    port               = 443
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval           = 30
  }
}
```

### 3. Listener Configuration
```hcl
# TCP Listener
resource "aws_lb_listener" "tcp" {
  load_balancer_arn = aws_lb.network.arn
  port              = "80"
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp.arn
  }
}

# UDP Listener
resource "aws_lb_listener" "udp" {
  load_balancer_arn = aws_lb.network.arn
  port              = "53"
  protocol          = "UDP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.udp.arn
  }
}

# TLS Listener
resource "aws_lb_listener" "tls" {
  load_balancer_arn = aws_lb.network.arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tls.arn
  }
}
```

### 4. Static IP Configuration
```hcl
# Elastic IP per subnet
resource "aws_eip" "nlb" {
  for_each = toset(var.public_subnet_ids)
  
  domain = "vpc"
  
  tags = {
    Name = "nlb-eip-${each.value}"
  }
}

# Associate EIPs with NLB
resource "aws_lb_subnet_mapping" "nlb" {
  for_each = aws_eip.nlb
  
  subnet_id     = each.key
  allocation_id = each.value.id
}
```

### 5. CloudWatch Monitoring
```hcl
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  for_each = {
    tcp = aws_lb_target_group.tcp.arn_suffix
    udp = aws_lb_target_group.udp.arn_suffix
    tls = aws_lb_target_group.tls.arn_suffix
  }
  
  alarm_name          = "${var.environment}-nlb-${each.key}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/NetworkELB"
  period             = "300"
  statistic          = "Average"
  threshold          = "0"
  alarm_description  = "Unhealthy hosts count is greater than 0 for ${each.key} target group"
  alarm_actions      = [var.sns_topic_arn]
  
  dimensions = {
    TargetGroup  = each.value
    LoadBalancer = aws_lb.network.arn_suffix
  }
}
```

## Validation Steps

1. Test TCP Connection
```bash
# Test TCP endpoint
nc -zv nlb.example.com 80

# Test connection with SSL/TLS
openssl s_client -connect nlb.example.com:443
```

2. Test UDP Connection
```bash
# Test DNS query (UDP)
dig @nlb.example.com example.com

# Test UDP connection
nc -zu nlb.example.com 53
```

3. Verify Static IPs
```bash
# Get NLB IP addresses
host nlb.example.com

# Compare with allocated EIPs
aws ec2 describe-addresses \
  --filters "Name=tag:Name,Values=nlb-eip-*"
```

4. Monitor Health Status
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $TARGET_GROUP_ARN

# View CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/NetworkELB \
  --metric-name HealthyHostCount \
  --dimensions Name=LoadBalancer,Value=$NLB_ARN_SUFFIX \
  --start-time $(date -d '1 hour ago' -u +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 300 \
  --statistics Average
```

## Common Issues and Solutions

1. Connection Timeouts
- Problem: Clients cannot connect to NLB
- Solution:
  - Verify security group rules
  - Check route table configuration
  - Validate target instance health

2. TLS Certificate Issues
- Problem: TLS handshake failures
- Solution:
  - Verify certificate domain
  - Check certificate validity
  - Confirm TLS policy settings

3. Static IP Problems
- Problem: NLB not using assigned EIPs
- Solution:
  - Verify subnet mappings
  - Check EIP associations
  - Validate network configuration

4. Health Check Failures
- Problem: Targets failing health checks
- Solution:
  - Check target application health
  - Verify network connectivity
  - Adjust health check settings

## Additional Resources

- [NLB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/)
- [TLS Listeners](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-tls-listener.html)
- [Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-target-groups.html)
- [Monitoring](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-monitoring.html) 