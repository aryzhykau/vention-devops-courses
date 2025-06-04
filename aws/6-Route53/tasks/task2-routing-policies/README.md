# Task 2: Route53 Routing Policies

This task guides you through implementing different routing policies in Amazon Route53.

## Objectives

1. Implement weighted routing for load distribution
2. Configure latency-based routing for optimal performance
3. Set up geolocation routing for regional traffic management
4. Create failover routing for high availability
5. Implement multi-value answer routing for DNS-based load balancing

## Prerequisites

- Completed Task 1: Basic Route53 Setup
- Multiple AWS regions with running resources
- Application Load Balancers or EC2 instances in different regions
- Basic understanding of DNS routing concepts

## Task Steps

### 1. Weighted Routing Setup

Implement weighted routing to distribute traffic between multiple endpoints:
- Primary endpoint (60% of traffic)
- Secondary endpoint (40% of traffic)

Example validation:
```bash
for i in {1..10}; do dig +short weighted.example.com; done
```

### 2. Latency-based Routing

Configure latency-based routing to direct users to the closest region:
- US West (Oregon) region
- US East (N. Virginia) region
- EU (Ireland) region
- AP (Tokyo) region

Example validation:
```bash
# Test from different locations using VPN or global testing tools
dig +short latency.example.com
```

### 3. Geolocation Routing

Set up geolocation routing based on user location:
- North America (US/Canada endpoints)
- Europe (EU endpoints)
- Asia Pacific (APAC endpoints)
- Default endpoint for other locations

Example validation:
```bash
# Test using VPN connections from different countries
dig +short geo.example.com
```

### 4. Failover Routing

Implement failover routing for high availability:
- Primary endpoint with health check
- Secondary endpoint for failover
- Monitoring and alerting for failover events

Example validation:
```bash
# Monitor health check status
aws route53 get-health-check-status --health-check-id <health-check-id>

# Test DNS resolution
dig +short failover.example.com
```

### 5. Multi-value Answer Routing

Configure multi-value answer routing for improved availability:
- Multiple endpoints with health checks
- Random selection of healthy endpoints
- Automatic removal of unhealthy endpoints

Example validation:
```bash
# Multiple DNS queries should return different healthy endpoints
for i in {1..5}; do dig +short multi.example.com; done
```

## Implementation Details

### 1. Weighted Routing
- Create weighted records with different weights
- Configure health checks for endpoints
- Set up CloudWatch monitoring

### 2. Latency-based Routing
- Deploy resources in multiple regions
- Create latency records for each region
- Configure regional health checks

### 3. Geolocation Routing
- Create location-based records
- Set up default routing
- Configure regional endpoints

### 4. Failover Routing
- Configure primary and secondary endpoints
- Set up health checks
- Create failover records

### 5. Multi-value Answer
- Create multiple records with health checks
- Configure response policies
- Set up monitoring

## Validation Steps

1. Test Weighted Distribution:
```bash
./test-weighted-distribution.sh weighted.example.com
```

2. Test Latency Routing:
```bash
./test-latency-routing.sh latency.example.com
```

3. Test Geolocation:
```bash
./test-geolocation.sh geo.example.com
```

4. Test Failover:
```bash
./test-failover.sh failover.example.com
```

5. Test Multi-value:
```bash
./test-multivalue.sh multi.example.com
```

## Expected Outcomes

After completing this task, you should have:
- Working weighted routing distribution
- Functional latency-based routing
- Properly configured geolocation routing
- Reliable failover setup
- Efficient multi-value answer routing

## Common Issues and Troubleshooting

1. Weighted Routing
- Issue: Uneven distribution
- Solution: Verify weight calculations and health check status

2. Latency Routing
- Issue: Unexpected region selection
- Solution: Check AWS latency measurements and region health

3. Geolocation
- Issue: Wrong region resolution
- Solution: Verify IP geolocation and record configuration

4. Failover
- Issue: No failover occurring
- Solution: Check health check configuration and thresholds

5. Multi-value
- Issue: Limited endpoint rotation
- Solution: Verify health check status and record configuration

## Additional Resources

- [Route53 Routing Policies](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html)
- [Health Check Types](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/health-checks-types.html)
- [DNS Failover Configuration](https://aws.amazon.com/blogs/networking-and-content-delivery/implementing-dns-failover-using-amazon-route-53/)
- [Latency-based Routing](https://aws.amazon.com/blogs/networking-and-content-delivery/using-latency-based-routing-with-amazon-route-53/) 