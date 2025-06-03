# Task 5: Monitoring and Optimization

This task demonstrates implementing comprehensive monitoring and optimization for EC2 instances using AWS monitoring services.

## Objectives
1. Configure CloudWatch monitoring
2. Set up custom metrics
3. Create monitoring dashboards
4. Implement cost optimization
5. Configure performance optimization

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured
- Basic understanding of monitoring concepts

## Implementation Steps

### 1. CloudWatch Setup
- Configure metrics
- Set up alarms
- Create dashboards
- Enable detailed monitoring

### 2. Custom Metrics Configuration
```json
{
  "MetricData": [
    {
      "MetricName": "MemoryUtilization",
      "Value": 85.5,
      "Unit": "Percent",
      "Dimensions": [
        {
          "Name": "InstanceId",
          "Value": "i-1234567890abcdef0"
        }
      ]
    }
  ],
  "Namespace": "Custom/EC2"
}
```

### 3. Cost Optimization
- Right-size instances
- Use Spot instances
- Implement auto-scaling
- Schedule workloads

### 4. Performance Tuning
- Monitor metrics
- Optimize resources
- Configure scaling
- Implement caching

## Architecture Diagram
```
                CloudWatch
                    |
            Custom Metrics
           /      |       \
     Memory    Network    Disk
      |          |         |
    EC2 Instance Monitoring
      |          |         |
   Alarms   Dashboards  Logs
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

4. Monitor metrics:
```bash
# Get metric statistics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time $(date -u -v-1H +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 300 \
  --statistics Average
```

## Validation Steps

1. Check CloudWatch Metrics:
```bash
aws cloudwatch list-metrics \
  --namespace AWS/EC2
```

2. View Alarms:
```bash
aws cloudwatch describe-alarms \
  --alarm-names CPUUtilizationAlarm
```

3. Test Custom Metrics:
```bash
aws cloudwatch put-metric-data \
  --namespace Custom/EC2 \
  --metric-name MemoryUtilization \
  --value 75.5 \
  --dimensions InstanceId=i-1234567890abcdef0
```

4. Monitor Performance:
```bash
aws cloudwatch get-metric-data \
  --metric-data-queries file://metric-query.json \
  --start-time 2024-01-01T00:00:00 \
  --end-time 2024-01-02T00:00:00
```

## Cleanup

To remove all resources:
```bash
# Delete alarms
aws cloudwatch delete-alarms \
  --alarm-names CPUUtilizationAlarm

# Delete dashboards
aws cloudwatch delete-dashboards \
  --dashboard-names monitoring-dashboard

# Remove custom metrics
aws cloudwatch delete-metrics \
  --namespace Custom/EC2

# Destroy infrastructure
terraform destroy
```

## Additional Notes
- Monitor regularly
- Adjust thresholds
- Update dashboards
- Document changes
- Review costs

## Troubleshooting

### Common Issues
1. Metric problems
   - Check namespace
   - Verify dimensions
   - Test data points

2. Alarm issues
   - Check thresholds
   - Verify actions
   - Test notifications

3. Dashboard problems
   - Check widgets
   - Verify metrics
   - Test refresh

### Logs Location
- CloudWatch logs
- System logs
- Application logs
- Custom logs

### Useful Commands
```bash
# Check metric statistics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time 2024-01-01T00:00:00 \
  --end-time 2024-01-02T00:00:00 \
  --period 300 \
  --statistics Average

# View log groups
aws logs describe-log-groups

# Test metric alarm
aws cloudwatch set-alarm-state \
  --alarm-name CPUUtilizationAlarm \
  --state-value ALARM \
  --state-reason "Testing alarm"
```

### Best Practices
1. Use appropriate metrics
2. Set meaningful thresholds
3. Create clear dashboards
4. Document changes
5. Regular reviews 