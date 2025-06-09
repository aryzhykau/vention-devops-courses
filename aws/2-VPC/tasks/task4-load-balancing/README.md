# Task 4: Load Balancing

## Overview
This task focuses on implementing various AWS load balancing solutions. You will learn how to set up Application Load Balancer (ALB), Network Load Balancer (NLB), and Gateway Load Balancer (GWLB) with proper target groups and health checks.

## Objectives
1. Set up Application Load Balancer
2. Configure Network Load Balancer
3. Implement Gateway Load Balancer
4. Set up target groups
5. Configure health checks

## Prerequisites
- AWS account with VPC access
- Existing VPC with public and private subnets
- AWS CLI configured
- Terraform installed
- Basic understanding of load balancing concepts

## Implementation Steps

### 1. Application Load Balancer
- Create ALB in public subnets
- Configure listener rules
- Set up target groups
- Implement SSL/TLS
- Configure access logs

### 2. Network Load Balancer
- Deploy NLB in public subnets
- Set up TCP/UDP listeners
- Configure target groups
- Implement cross-zone balancing
- Set up health checks

### 3. Gateway Load Balancer
- Create GWLB for security appliances
- Configure endpoint service
- Set up target groups
- Implement health checks
- Configure routing

### 4. Target Groups
- Create EC2 target groups
- Set up IP target groups
- Configure Lambda targets
- Implement sticky sessions
- Set up deregistration delay

### 5. Health Checks
- Configure HTTP/HTTPS checks
- Set up TCP checks
- Implement custom checks
- Configure thresholds
- Set up monitoring

## Validation Criteria
- [ ] ALB properly configured
- [ ] NLB working correctly
- [ ] GWLB operational
- [ ] Target groups functioning
- [ ] Health checks active

## Security Considerations
- Enable access logging
- Configure SSL/TLS
- Implement security groups
- Monitor health status
- Regular security updates

## Additional Resources
- [Application Load Balancers](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [Network Load Balancers](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html)
- [Gateway Load Balancers](https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/introduction.html)
- [Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html)
- [Health Checks](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html) 