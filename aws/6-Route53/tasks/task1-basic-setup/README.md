# Task 1: Basic Route53 Setup

This task guides you through setting up basic DNS configuration using Amazon Route53.

## Objectives

1. Create a public hosted zone
2. Configure basic DNS records
3. Set up health checks
4. Create aliases for AWS resources
5. Implement basic monitoring

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed (v1.0.0+)
- Domain name available for registration or transfer
- Basic understanding of DNS concepts

## Task Steps

### 1. Create Public Hosted Zone

Create a public hosted zone for your domain:
```bash
terraform init
terraform plan
terraform apply
```

This will:
- Create a public hosted zone
- Configure name servers
- Set up basic zone settings

### 2. Configure DNS Records

Add the following record types:
- A record for IPv4 addresses
- AAAA record for IPv6 addresses
- CNAME record for subdomains
- MX records for email routing
- TXT records for domain verification

### 3. Set Up Health Checks

Configure health checks to monitor:
- Website availability
- API endpoints
- Email servers
- Custom application endpoints

### 4. Create AWS Resource Aliases

Set up aliases for:
- Application Load Balancer
- CloudFront distribution
- S3 bucket website
- API Gateway endpoints

### 5. Implement Monitoring

Configure:
- CloudWatch alarms for health checks
- DNS query logging
- Metric monitoring
- Alert notifications

## Validation Steps

1. Verify DNS Resolution:
```bash
dig example.com
dig www.example.com
```

2. Check Health Status:
```bash
aws route53 get-health-check-status --health-check-id <health-check-id>
```

3. Test Aliases:
```bash
curl -v https://www.example.com
curl -v https://api.example.com
```

4. Verify Monitoring:
- Check CloudWatch dashboards
- Review health check metrics
- Confirm alert configurations

## Expected Outcome

After completing this task, you should have:
- A fully functional public hosted zone
- Properly configured DNS records
- Working health checks
- Functional AWS resource aliases
- Active monitoring and alerting

## Common Issues and Troubleshooting

1. DNS Propagation
- Issue: DNS changes not immediately visible
- Solution: Wait for TTL period to expire

2. Health Check Failures
- Issue: False positive health check failures
- Solution: Adjust thresholds and monitoring intervals

3. Alias Record Issues
- Issue: Alias target not accessible
- Solution: Verify target resource configuration

4. Monitoring Alerts
- Issue: Missing or delayed alerts
- Solution: Check CloudWatch configurations

## Additional Resources

- [Route53 Developer Guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)
- [Terraform Route53 Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)
- [AWS DNS Best Practices](https://aws.amazon.com/blogs/networking-and-content-delivery/category/networking-content-delivery/amazon-route-53/) 