# Task 1: Basic Instance Management

This task demonstrates the fundamental operations of EC2 instance management, including launching, configuring, and managing EC2 instances.

## Objectives
1. Launch EC2 instances with different configurations
2. Configure security groups and networking
3. Manage key pairs and SSH access
4. Work with EBS volumes and snapshots

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured
- Basic understanding of Linux/Unix commands

## Implementation Steps

### 1. VPC Configuration
- Create VPC
- Configure subnets
- Set up internet gateway
- Configure route tables

### 2. Security Setup
```json
{
  "SecurityGroups": [
    {
      "GroupName": "WebServerSG",
      "Description": "Security group for web servers",
      "IpPermissions": [
        {
          "IpProtocol": "tcp",
          "FromPort": 80,
          "ToPort": 80,
          "IpRanges": [{"CidrIp": "0.0.0.0/0"}]
        },
        {
          "IpProtocol": "tcp",
          "FromPort": 22,
          "ToPort": 22,
          "IpRanges": [{"CidrIp": "YOUR_IP/32"}]
        }
      ]
    }
  ]
}
```

### 3. Instance Launch
- Select AMI
- Choose instance type
- Configure networking
- Add storage
- Configure tags

### 4. Storage Management
- Create EBS volumes
- Attach volumes
- Create snapshots
- Implement backup strategy

## Architecture Diagram
```
                Internet Gateway
                      |
                     VPC
                      |
                   Subnet
                      |
                EC2 Instance
                /     |     \
           EBS    Security   Key
         Volume    Group     Pair
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

4. Connect to instance:
```bash
# Using SSH key
ssh -i "your-key.pem" ec2-user@your-instance-ip

# Using AWS Systems Manager
aws ssm start-session --target i-1234567890abcdef0
```

## Validation Steps

1. Check Instance Status:
```bash
aws ec2 describe-instance-status --instance-ids i-1234567890abcdef0
```

2. Verify Security Group:
```bash
aws ec2 describe-security-groups --group-ids sg-1234567890abcdef0
```

3. Test Volume Status:
```bash
aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=i-1234567890abcdef0
```

4. Check System Logs:
```bash
aws ec2 get-console-output --instance-id i-1234567890abcdef0
```

## Cleanup

To remove all resources:
```bash
# Detach and delete volumes
aws ec2 detach-volume --volume-id vol-1234567890abcdef0
aws ec2 delete-volume --volume-id vol-1234567890abcdef0

# Terminate instance
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# Destroy infrastructure
terraform destroy
```

## Additional Notes
- Keep track of running instances
- Monitor EBS volumes
- Regularly update security groups
- Maintain backup snapshots
- Document configurations

## Troubleshooting

### Common Issues
1. Connection problems
   - Check security groups
   - Verify key pair
   - Test network connectivity

2. Volume issues
   - Check device naming
   - Verify attachments
   - Monitor volume status

3. Performance problems
   - Monitor CPU usage
   - Check memory utilization
   - Review network performance

### Logs Location
- System logs
- Application logs
- CloudWatch logs
- VPC flow logs

### Useful Commands
```bash
# Get instance metadata
curl http://169.254.169.254/latest/meta-data/

# Check system resources
top
df -h
free -m

# Monitor logs
tail -f /var/log/syslog
```

### Best Practices
1. Use appropriate instance types
2. Implement proper security
3. Regular backups
4. Monitor resources
5. Document configurations 