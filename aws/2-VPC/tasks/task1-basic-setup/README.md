# Task 1: Basic VPC Setup

This task demonstrates setting up a basic VPC configuration with public and private subnets using Terraform.

## Objectives
1. Create a VPC with custom CIDR block
2. Set up public and private subnets in multiple AZs
3. Configure Internet Gateway and routing
4. Create and configure route tables
5. Set up basic security group

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured

## Implementation Steps

### 1. VPC Configuration
- Creates a VPC with CIDR block 10.0.0.0/16
- Enables DNS hostnames and DNS support
- Tags the VPC for identification

### 2. Subnet Layout
Creates four subnets:
- Public Subnet 1 (10.0.1.0/24) in us-west-2a
- Public Subnet 2 (10.0.2.0/24) in us-west-2b
- Private Subnet 1 (10.0.3.0/24) in us-west-2a
- Private Subnet 2 (10.0.4.0/24) in us-west-2b

### 3. Internet Connectivity
- Creates and attaches Internet Gateway
- Configures public route table with internet access
- Sets up private route table for internal routing

### 4. Route Tables
- Creates separate route tables for public and private subnets
- Associates subnets with appropriate route tables
- Configures internet access for public subnets

### 5. Security
- Creates default security group
- Allows internal VPC communication
- Permits outbound internet access
- Configures basic security rules

## Architecture Diagram
```
                                  VPC (10.0.0.0/16)
                                         |
                                 Internet Gateway
                                         |
                    +-------------------+-------------------+
                    |                                      |
            Public Subnet 1                        Public Subnet 2
            (10.0.1.0/24)                         (10.0.2.0/24)
            us-west-2a                            us-west-2b
                    |                                      |
                    |                                      |
            Private Subnet 1                      Private Subnet 2
            (10.0.3.0/24)                         (10.0.4.0/24)
            us-west-2a                            us-west-2b
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

## Validation Steps

1. Check VPC Creation:
```bash
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=main"
```

2. Verify Subnet Configuration:
```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"
```

3. Test Internet Connectivity:
```bash
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=<vpc-id>"
```

## Cleanup

To remove all resources:
```bash
terraform destroy
```

## Additional Notes
- Remember to adjust CIDR ranges based on your requirements
- Consider adding NAT Gateway for private subnet internet access
- Review security group rules for production use
- Monitor VPC resource limits
- Consider enabling VPC flow logs for security monitoring 