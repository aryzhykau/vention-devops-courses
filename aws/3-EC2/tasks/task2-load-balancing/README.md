# Task 2: Load Balancing and Auto Scaling

This task demonstrates setting up load balancing and auto scaling for EC2 instances to handle varying workloads efficiently.

## Objectives
1. Configure Application Load Balancer
2. Set up Auto Scaling Group
3. Implement scaling policies
4. Monitor performance metrics

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured
- Basic understanding of load balancing concepts

## Implementation Steps

### 1. Load Balancer Setup
- Create target group
- Configure health checks
- Set up listeners
- Implement routing rules

### 2. Auto Scaling Configuration
```json
{
  "AutoScalingGroup": {
    "MinSize": 2,
    "MaxSize": 10,
    "DesiredCapacity": 2,
    "HealthCheckType": "ELB",
    "HealthCheckGracePeriod": 300,
    "LaunchTemplate": {
      "Version": "Latest"
    },
    "TargetGroupARNs": ["arn:aws:elasticloadbalancing:region:account:targetgroup/example/1234567890"]
  }
}
```

### 3. Scaling Policies
- Target tracking scaling
- Step scaling
- Simple scaling
- Scheduled scaling

### 4. Monitoring Setup
- Configure CloudWatch metrics
- Set up alarms
- Implement notifications
- Create dashboards

## Architecture Diagram
```
                Application Load Balancer
                          |
                Auto Scaling Group
                /         |          \
           EC2        EC2         EC2
        Instance   Instance    Instance
           |          |          |
        Target     Target     Target
        Group      Group      Group
```

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the execution plan:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. Test scaling:
```bash
# Generate load
ab -n 10000 -c 100 http://your-alb-dns-name/

# Check scaling activity
aws autoscaling describe-scaling-activities --auto-scaling-group-name your-asg-name
```

## Validation Steps

1. Check Load Balancer Health:
```bash
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/example/1234567890
```

2. Monitor Auto Scaling:
```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names your-asg-name
```

3. View Scaling History:
```bash
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name your-asg-name
```

4. Check CloudWatch Metrics:
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancer,Value=your-alb-name \
  --start-time $(date -u -v-1H +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 300 \
  --statistics Sum
```

## Cleanup

To remove all resources:
```bash
# Update Auto Scaling Group
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name your-asg-name \
  --min-size 0 \
  --max-size 0 \
  --desired-capacity 0

# Wait for instances to terminate
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names your-asg-name

# Delete Auto Scaling Group
aws autoscaling delete-auto-scaling-group \
  --auto-scaling-group-name your-asg-name

# Delete Load Balancer
aws elbv2 delete-load-balancer \
  --load-balancer-arn your-alb-arn

# Destroy infrastructure
terraform destroy
```

## Additional Notes
- Monitor scaling events
- Review performance metrics
- Adjust scaling thresholds
- Test failover scenarios
- Document configurations

## Troubleshooting

### Common Issues
1. Scaling problems
   - Check scaling policies
   - Verify launch template
   - Monitor capacity limits

2. Load balancer issues
   - Check target health
   - Verify security groups
   - Test health checks

3. Performance problems
   - Monitor request counts
   - Check latency metrics
   - Review error rates

### Logs Location
- ALB access logs
- CloudWatch logs
- Auto Scaling logs
- EC2 instance logs

### Useful Commands
```bash
# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn your-target-group-arn

# View scaling activities
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name your-asg-name

# Monitor metrics
aws cloudwatch get-metric-data \
  --metric-data-queries file://metric-query.json \
  --start-time 2024-01-01T00:00:00 \
  --end-time 2024-01-02T00:00:00
```

### Best Practices
1. Use appropriate scaling metrics
2. Implement proper health checks
3. Configure appropriate thresholds
4. Monitor performance regularly
5. Document scaling patterns 