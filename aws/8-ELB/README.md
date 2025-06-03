# Amazon Elastic Load Balancer (ELB) Training Module

This module provides hands-on training for AWS Elastic Load Balancer services, including Application Load Balancer (ALB), Network Load Balancer (NLB), and Gateway Load Balancer (GWLB).

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Terraform installed (v1.0.0+)
- Basic understanding of networking concepts
- Completed VPC and EC2 modules

## Learning Objectives

After completing this module, you will be able to:

1. Understand ELB concepts:
   - Load balancer types and use cases
   - Target groups and health checks
   - Listeners and rules
   - SSL/TLS termination
   - Access logs and monitoring

2. Implement different types of load balancers:
   - Application Load Balancer (Layer 7)
   - Network Load Balancer (Layer 4)
   - Gateway Load Balancer (Layer 3)

## Module Structure

```
09-ELB/
├── docs/
│   ├── concepts.md
│   └── best-practices.md
└── tasks/
    ├── task1-alb/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── task2-nlb/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## Tasks Overview

### Task 1: Application Load Balancer (ALB)
- Create ALB with multiple target groups
- Configure path-based routing
- Set up SSL/TLS termination
- Implement authentication
- Configure access logs
- Set up monitoring and alerts

### Task 2: Network Load Balancer (NLB)
- Create NLB with TCP/UDP listeners
- Configure static IP addresses
- Set up TLS termination
- Implement cross-zone load balancing
- Configure health checks
- Monitor performance

## Validation Steps

1. ALB Validation:
```bash
# Test path-based routing
curl -v http://alb.example.com/api/
curl -v http://alb.example.com/static/

# Test SSL/TLS
curl -v https://alb.example.com/

# Test authentication
curl -v -H "Authorization: Bearer token" https://alb.example.com/secure/
```

2. NLB Validation:
```bash
# Test TCP connection
nc -zv nlb.example.com 80
nc -zv nlb.example.com 443

# Test UDP connection
nc -zu nlb.example.com 53
```

## Common Issues and Solutions

1. Health Check Issues
- Problem: Targets failing health checks
- Solution: Verify security groups, routes, and health check settings

2. SSL/TLS Problems
- Problem: Certificate errors
- Solution: Check certificate validity and configuration

3. Routing Issues
- Problem: Requests not reaching correct targets
- Solution: Verify listener rules and target group settings

4. Performance Problems
- Problem: High latency or connection failures
- Solution: Check target group scaling and cross-zone settings

## Additional Resources

- [ELB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/)
- [ALB User Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [NLB User Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/)
- [GWLB User Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/) 