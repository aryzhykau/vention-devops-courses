# Amazon Route53 Training Module

This module provides hands-on training for Amazon Route53, AWS's scalable Domain Name System (DNS) web service.

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Terraform installed (v1.0.0+)
- Basic understanding of DNS concepts
- Completed VPC and EC2 modules

## Learning Objectives

After completing this module, you will be able to:

1. Understand Route53 core concepts:
   - Hosted Zones (Public and Private)
   - Record Sets
   - Health Checks
   - Traffic Policies
   - DNS Failover
   - Geolocation Routing
   - Latency-based Routing
   - Weighted Routing
   - Multi-value Answer Routing

2. Implement Route53 configurations:
   - Create and manage hosted zones
   - Configure different types of DNS records
   - Set up health checks and DNS failover
   - Implement various routing policies
   - Integrate with other AWS services

3. Follow AWS best practices for:
   - DNS management
   - High availability
   - Domain registration
   - DNS security
   - Cost optimization

## Module Structure

```
06-Route53/
├── docs/
│   ├── concepts.md
│   └── best-practices.md
└── tasks/
    ├── task1-basic-setup/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── task2-routing-policies/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
  
```

## Tasks Overview

### Task 1: Basic Route53 Setup
- Create a public hosted zone
- Configure basic DNS records (A, CNAME, MX)
- Set up domain registration
- Implement basic health checks
- Create aliases for AWS resources

### Task 2: Route53 Routing Policies
- Implement weighted routing
- Configure latency-based routing
- Set up geolocation routing
- Create failover routing
- Implement multi-value answer routing

## Validation

Each task includes validation steps to ensure proper implementation:

1. DNS record validation using `dig` or `nslookup`
2. Health check monitoring
3. Routing policy verification
4. Latency and availability testing
5. Security configuration validation

## Additional Resources

- [Route53 Developer Guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)
- [Route53 API Reference](https://docs.aws.amazon.com/Route53/latest/APIReference/Welcome.html)
- [AWS DNS Best Practices](https://aws.amazon.com/blogs/networking-and-content-delivery/category/networking-content-delivery/amazon-route-53/)
- [Route53 Pricing](https://aws.amazon.com/route53/pricing/)
- [AWS Solutions Architect Blog - DNS Patterns](https://aws.amazon.com/blogs/architecture/) 