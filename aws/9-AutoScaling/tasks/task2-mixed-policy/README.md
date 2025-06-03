# Task 2: Mixed Instance Policy Implementation

This task guides you through implementing an Auto Scaling Group with mixed instance types and spot instances for cost optimization.

## Prerequisites

- AWS Account with appropriate permissions
- Terraform installed (v1.0.0+)
- AWS CLI configured
- Completed Task 1 (Basic ASG)
- Understanding of EC2 instance types and spot instances

## Task Objectives

1. Configure mixed instance types
2. Implement spot instance strategies
3. Set up capacity optimization
4. Configure instance distribution
5. Implement capacity rebalancing

## Implementation Steps

### 1. Mixed Instance Policy Configuration
```hcl
resource "aws_autoscaling_group" "mixed" {
  name                = "mixed-instance-asg"
  desired_capacity    = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.subnet_ids

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.app.id
        version           = "$Latest"
      }

      override {
        instance_type     = "t3.micro"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "t3a.micro"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "t2.micro"
        weighted_capacity = "1"
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "capacity-optimized"
      spot_instance_pools                      = 0
    }
  }
}
```

### 2. Spot Instance Configuration
```hcl
resource "aws_launch_template" "app" {
  name_prefix   = "app-template"
  image_id      = var.ami_id

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = var.spot_price
    }
  }

  # Other launch template configurations...
}
```

### 3. Capacity Rebalancing
```hcl
resource "aws_autoscaling_group" "mixed" {
  capacity_rebalance = true

  # Other ASG configurations...
}
```

## Validation Steps

1. Verify Instance Distribution
```bash
# Check running instances
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-name mixed-instance-asg \
  --query 'AutoScalingGroups[].Instances[].[InstanceId,InstanceType,LifecycleState]'

# Check spot instances
aws ec2 describe-instances \
  --filters "Name=instance-lifecycle,Values=spot" \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,SpotInstanceRequestId]'
```

2. Monitor Spot Interruptions
```bash
# Check spot instance interruption notifications
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2Spot \
  --metric-name SpotInstanceInterruption \
  --dimensions Name=AutoScalingGroupName,Value=mixed-instance-asg \
  --start-time $(date -d '1 hour ago' -u +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 300 \
  --statistics Sum
```

3. Test Capacity Rebalancing
```bash
# Simulate spot instance interruption
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name mixed-instance-asg \
  --preferences '{"InstanceWarmup": 300, "MinHealthyPercentage": 90}'
```

## Common Issues and Solutions

1. Spot Capacity Issues
- Problem: No spot instances available
- Solution:
  - Use multiple instance types
  - Configure appropriate max price
  - Use capacity-optimized allocation strategy

2. Instance Distribution Problems
- Problem: Uneven distribution of instance types
- Solution:
  - Adjust weighted capacity
  - Review on-demand percentage
  - Check instance type availability

3. Cost Management
- Problem: Higher than expected costs
- Solution:
  - Monitor spot vs on-demand ratio
  - Review instance type selection
  - Adjust capacity settings

## Best Practices

1. Instance Selection
- Choose similar instance types
- Consider price-performance ratio
- Use multiple instance families
- Select appropriate sizes

2. Spot Configuration
- Set appropriate max price
- Use capacity-optimized strategy
- Implement proper interruption handling
- Monitor spot market prices

3. Capacity Management
- Configure proper base capacity
- Set appropriate percentage above base
- Use multiple Availability Zones
- Implement proper monitoring

4. Cost Optimization
- Monitor instance distribution
- Track spot savings
- Review capacity utilization
- Implement proper tagging

## Additional Resources

- [Mixed Instances Policy Documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-purchase-options.html)
- [Spot Instances Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html)
- [Capacity Rebalancing](https://docs.aws.amazon.com/autoscaling/ec2/userguide/capacity-rebalance.html)
- [Instance Type Selection](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html) 