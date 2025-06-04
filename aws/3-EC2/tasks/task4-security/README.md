# Task 4: Security Implementation

This task demonstrates implementing comprehensive security measures for EC2 instances using AWS security features and best practices.

## Objectives
1. Configure IAM roles and policies
2. Implement security groups and NACLs
3. Set up encryption and key management
4. Configure security monitoring
5. Implement compliance controls

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured
- Basic understanding of AWS security concepts

## Implementation Steps

### 1. IAM Configuration
- Create service roles
- Set up instance profiles
- Configure policies
- Implement least privilege

### 2. Network Security
```json
{
  "NetworkAcl": {
    "Entries": [
      {
        "RuleNumber": 100,
        "Protocol": "tcp",
        "RuleAction": "allow",
        "Egress": false,
        "CidrBlock": "0.0.0.0/0",
        "PortRange": {
          "From": 80,
          "To": 80
        }
      },
      {
        "RuleNumber": 200,
        "Protocol": "tcp",
        "RuleAction": "allow",
        "Egress": false,
        "CidrBlock": "YOUR_IP/32",
        "PortRange": {
          "From": 22,
          "To": 22
        }
      }
    ]
  }
}
```

### 3. Encryption Setup
- Configure KMS keys
- Set up EBS encryption
- Implement SSL/TLS
- Secure secrets

### 4. Monitoring Configuration
- Set up CloudTrail
- Configure VPC Flow Logs
- Enable GuardDuty
- Implement AWS Config

## Architecture Diagram
```
                   AWS Organizations
                          |
                    Security Hub
                    /    |    \
              Config  GuardDuty  CloudTrail
                    \    |    /
                      EC2/VPC
                    /    |    \
                 IAM   KMS    CloudWatch
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

4. Verify security:
```bash
# Check security groups
aws ec2 describe-security-groups

# Verify IAM roles
aws iam list-roles

# Check encryption status
aws ec2 describe-volumes --filters Name=encrypted,Values=true
```

## Validation Steps

1. Check IAM Configuration:
```bash
aws iam get-role \
  --role-name your-role-name

aws iam simulate-principal-policy \
  --policy-source-arn your-role-arn \
  --action-names ec2:DescribeInstances
```

2. Verify Network Security:
```bash
aws ec2 describe-network-acls
aws ec2 describe-security-groups
aws ec2 describe-flow-logs
```

3. Test Encryption:
```bash
aws kms list-keys
aws ec2 describe-volumes \
  --filters Name=encrypted,Values=true
```

4. Monitor Security Events:
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin

aws guardduty list-findings \
  --detector-id your-detector-id
```

## Cleanup

To remove all resources:
```bash
# Delete KMS keys
aws kms schedule-key-deletion \
  --key-id your-key-id \
  --pending-window-in-days 7

# Remove IAM roles
aws iam delete-role \
  --role-name your-role-name

# Disable security services
aws guardduty delete-detector \
  --detector-id your-detector-id

aws securityhub disable-security-hub

# Destroy infrastructure
terraform destroy
```

## Additional Notes
- Regularly rotate credentials
- Monitor security events
- Update security policies
- Document configurations
- Train team members

## Troubleshooting

### Common Issues
1. Permission problems
   - Check IAM policies
   - Verify role trust
   - Test access

2. Network issues
   - Check security groups
   - Verify NACLs
   - Test connectivity

3. Encryption problems
   - Verify KMS access
   - Check key policies
   - Test encryption

### Logs Location
- CloudTrail logs
- VPC Flow Logs
- CloudWatch logs
- GuardDuty findings

### Useful Commands
```bash
# Check IAM permissions
aws iam get-user
aws iam list-attached-user-policies

# Test network access
aws ec2 describe-network-interfaces
aws ec2 describe-vpc-endpoints

# Verify encryption
aws kms list-aliases
aws ec2 describe-volumes
```

### Best Practices
1. Use least privilege
2. Enable encryption
3. Monitor access
4. Regular audits
5. Document changes 