# Task 3: High Availability Setup

This task demonstrates implementing a highly available architecture using EC2 instances across multiple Availability Zones.

## Objectives
1. Configure Multi-AZ deployment
2. Implement failover mechanisms
3. Set up disaster recovery
4. Create backup strategies

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured
- Basic understanding of high availability concepts

## Implementation Steps

### 1. Multi-AZ Configuration
- Deploy across AZs
- Configure networking
- Set up load balancing
- Implement redundancy

### 2. Failover Setup
```json
{
  "Route53HealthCheck": {
    "Type": "AWS::Route53::HealthCheck",
    "Properties": {
      "HealthCheckConfig": {
        "Port": 80,
        "Type": "HTTP",
        "ResourcePath": "/health",
        "FullyQualifiedDomainName": "example.com",
        "RequestInterval": 30,
        "FailureThreshold": 3
      }
    }
  }
}
```

### 3. Disaster Recovery
- Configure backups
- Set up snapshots
- Implement recovery procedures
- Test failover

### 4. Monitoring Setup
- Configure health checks
- Set up alerts
- Monitor metrics
- Implement logging

## Architecture Diagram
```
                Route 53
                   |
           Application Load Balancer
          /         |           \
     AZ-1        AZ-2         AZ-3
      |           |             |
    EC2 +       EC2 +        EC2 +
    EBS         EBS          EBS
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

4. Test failover:
```bash
# Simulate instance failure
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Monitor failover
aws autoscaling describe-scaling-activities --auto-scaling-group-name your-asg-name
```

## Validation Steps

1. Check Multi-AZ Status:
```bash
aws ec2 describe-instances \
  --filters "Name=tag:aws:autoscaling:groupName,Values=your-asg-name" \
  --query 'Reservations[].Instances[].{ID:InstanceId,AZ:Placement.AvailabilityZone}'
```

2. Verify Health Checks:
```bash
aws route53 get-health-check \
  --health-check-id your-health-check-id
```

3. Test Recovery:
```bash
# Create snapshot
aws ec2 create-snapshot \
  --volume-id vol-1234567890abcdef0 \
  --description "Backup for disaster recovery"

# Restore from snapshot
aws ec2 create-volume \
  --snapshot-id snap-1234567890abcdef0 \
  --availability-zone us-west-2a
```

4. Monitor Metrics:
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name StatusCheckFailed \
  --dimensions Name=AutoScalingGroupName,Value=your-asg-name \
  --start-time $(date -u -v-1H +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 300 \
  --statistics Maximum
```

## Cleanup

To remove all resources:
```bash
# Delete snapshots
aws ec2 delete-snapshot --snapshot-id snap-1234567890abcdef0

# Terminate instances
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name your-asg-name \
  --min-size 0 \
  --max-size 0 \
  --desired-capacity 0

# Delete health checks
aws route53 delete-health-check \
  --health-check-id your-health-check-id

# Destroy infrastructure
terraform destroy
```

## Additional Notes
- Test failover regularly
- Monitor system health
- Update recovery procedures
- Document configurations
- Train team members

## Troubleshooting

### Common Issues
1. Failover problems
   - Check health checks
   - Verify networking
   - Monitor instance status

2. Backup issues
   - Verify snapshot status
   - Check storage capacity
   - Monitor backup jobs

3. Recovery problems
   - Test restore procedures
   - Verify data integrity
   - Check system state

### Logs Location
- CloudWatch logs
- System logs
- Application logs
- Backup logs

### Useful Commands
```bash
# Check instance health
aws ec2 describe-instance-status \
  --instance-ids i-1234567890abcdef0

# List snapshots
aws ec2 describe-snapshots \
  --owner-ids self

# Monitor health checks
aws route53 get-health-check-status \
  --health-check-id your-health-check-id
```

### Best Practices
1. Regular failover testing
2. Automated backups
3. Documented procedures
4. Monitoring and alerts
5. Team training 