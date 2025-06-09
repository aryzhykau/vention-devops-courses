# Task 2: High Availability Setup

## Overview
This task focuses on implementing a high-availability architecture using AWS Free Tier compatible services. You will learn how to set up redundant systems, configure auto-scaling, and implement failover mechanisms.

## Objectives
1. Configure Multi-AZ architecture with t2.micro instances
2. Set up Auto Scaling groups
3. Implement Route 53 health checks and DNS failover
4. Configure Application Load Balancer
5. Set up CloudWatch monitoring and alerts

## AWS Free Tier Considerations
- EC2: t2.micro instances (750 hours per month)
- ELB: 750 hours per month
- Route 53: Health checks (50 checks free)
- CloudWatch: Basic monitoring
- Auto Scaling: No additional charge

## Implementation Steps

### 1. Multi-AZ Setup
- Create VPC with multiple AZs
- Launch t2.micro instances across AZs
- Configure security groups
- Set up instance profiles

### 2. Auto Scaling Configuration
- Create launch template
- Configure Auto Scaling group
- Set up scaling policies
- Define health checks

### 3. Load Balancer Setup
- Configure Application Load Balancer
- Set up target groups
- Configure health checks
- Implement SSL termination

### 4. DNS and Monitoring
- Configure Route 53 health checks
- Set up DNS failover routing
- Create CloudWatch alarms
- Configure SNS notifications

## Validation Criteria
- [ ] Multi-AZ deployment successful
- [ ] Auto Scaling working correctly
- [ ] Load balancer properly configured
- [ ] Health checks passing
- [ ] Monitoring and alerts functional

## Additional Resources
- [AWS Auto Scaling Documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html)
- [Elastic Load Balancing Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [Route 53 Health Checks](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-types.html) 