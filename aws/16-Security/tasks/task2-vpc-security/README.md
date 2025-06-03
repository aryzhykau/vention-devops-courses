# Task 2: VPC Security

This task focuses on implementing secure VPC architecture with network security best practices while staying within Free Tier limits.

## Objectives

1. Create a secure VPC architecture
2. Implement network segmentation
3. Configure security groups and NACLs
4. Set up VPC Flow Logs
5. Deploy a secure bastion host
6. Implement VPC endpoints
7. Configure monitoring and alerting

## Prerequisites

- AWS Account with Free Tier access
- AWS CLI configured
- Terraform installed
- Basic understanding of networking concepts
- Completed Task 1 (IAM Fundamentals)

## Architecture Overview

```plaintext
                                     ┌──────────────┐
                                     │   Internet   │
                                     └──────┬───────┘
                                            │
                                     ┌──────┴───────┐
                                     │     IGW      │
                                     └──────┬───────┘
                                            │
                    ┌────────────────┬──────┴───────┬────────────────┐
                    │                │              │                │
              ┌─────┴─────┐    ┌─────┴─────┐  ┌─────┴─────┐  ┌─────┴─────┐
              │  Public    │    │  Public    │  │  Private   │  │  Private   │
              │  Subnet 1  │    │  Subnet 2  │  │  Subnet 1  │  │  Subnet 2  │
              └─────┬─────┘    └────────────┘  └─────┬─────┘  └────────────┘
                    │                                 │
              ┌─────┴─────┐                    ┌─────┴─────┐
              │  Bastion   │                    │    NAT    │
              │   Host     │                    │  Gateway  │
              └───────────┘                    └───────────┘
```

## Task Steps

### 1. VPC Configuration

```hcl
# Example terraform.tfvars
project_name = "secure-vpc"
vpc_cidr     = "10.0.0.0/16"

public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
```

### 2. Security Group Configuration

```hcl
# Example terraform.tfvars
allowed_ssh_cidrs = ["YOUR_IP/32"]
allowed_http_cidrs = ["0.0.0.0/0"]
```

### 3. Network ACL Rules

```hcl
# Example terraform.tfvars
custom_nacl_rules = [
  {
    rule_number = 100
    egress     = false
    protocol   = "tcp"
    rule_action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  },
  {
    rule_number = 110
    egress     = false
    protocol   = "tcp"
    rule_action = "allow"
    cidr_block = "YOUR_IP/32"
    from_port  = 22
    to_port    = 22
  }
]
```

### 4. Flow Logs Configuration

```hcl
# Example terraform.tfvars
enable_flow_logs = true
flow_logs_retention_days = 7
```

### 5. VPC Endpoints

```hcl
# Example terraform.tfvars
enable_s3_endpoint = true
enable_dynamodb_endpoint = false
```

### 6. Monitoring Configuration

```hcl
# Example terraform.tfvars
enable_monitoring = true
```

## Implementation Steps

1. Clone the repository
2. Navigate to the task directory:
   ```bash
   cd aws/16-Security/tasks/task2-vpc-security
   ```

3. Create a `terraform.tfvars` file with your configurations

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Review the plan:
   ```bash
   terraform plan
   ```

6. Apply the configuration:
   ```bash
   terraform apply
   ```

## Validation Steps

1. Verify VPC Configuration:
   ```bash
   aws ec2 describe-vpcs --filters "Name=tag:Name,Values=secure-vpc"
   ```

2. Test Bastion Access:
   ```bash
   ssh -i your-key.pem ec2-user@BASTION_IP
   ```

3. Verify Flow Logs:
   ```bash
   aws logs describe-log-groups --log-group-name-prefix "/aws/vpc/flow-logs"
   ```

4. Check Security Groups:
   ```bash
   aws ec2 describe-security-groups --filters "Name=vpc-id,Values=VPC_ID"
   ```

5. Test VPC Endpoints:
   ```bash
   aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=VPC_ID"
   ```

## Clean Up

To remove all created resources:
```bash
terraform destroy
```

## Best Practices Implemented

1. **Network Segmentation**
   - Public/private subnets
   - Network ACLs
   - Security groups
   - Bastion host

2. **Access Control**
   - Limited SSH access
   - Bastion host pattern
   - Security group rules
   - NACL rules

3. **Monitoring**
   - VPC Flow Logs
   - CloudWatch metrics
   - Network monitoring
   - Security alerts

4. **Cost Optimization**
   - Single NAT Gateway
   - Free Tier instance
   - Minimal logging
   - Optimized endpoints

## Free Tier Considerations

This implementation stays within Free Tier limits by:
- Using t2.micro for bastion host
- Minimizing NAT Gateway usage
- Limited Flow Logs retention
- Basic monitoring setup
- Minimal VPC endpoints

## Next Steps

After completing this task:
1. Implement WAF rules
2. Add VPN access
3. Enhance monitoring
4. Implement GuardDuty
5. Add encryption

## Troubleshooting

Common issues and solutions:

1. **Connectivity Issues**
   - Check route tables
   - Verify security groups
   - Test NACL rules
   - Validate endpoints

2. **Bastion Access**
   - Verify key pair
   - Check security group
   - Test SSH access
   - Validate network

3. **Flow Logs**
   - Check IAM roles
   - Verify CloudWatch
   - Test logging
   - Monitor metrics

## Additional Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Security Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)
- [VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints.html) 