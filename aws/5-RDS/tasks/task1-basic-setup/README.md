# Task 1: Basic RDS Setup

## Overview
This task guides you through the process of setting up a basic Amazon RDS instance using Terraform. You'll learn how to create and configure a MySQL database instance with proper networking, security, and basic monitoring.

## Objectives
1. Create a VPC with proper networking for RDS
2. Set up security groups and subnet groups
3. Deploy a basic RDS instance
4. Configure basic monitoring and backups
5. Test database connectivity

## Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform installed (version 1.0.0 or higher)
- Basic understanding of SQL and databases
- MySQL client installed locally

## Steps

### 1. Network Setup
First, we'll create the necessary network infrastructure:
- VPC with appropriate CIDR block
- Public and private subnets across two AZs
- Internet Gateway and NAT Gateway
- Route tables for public and private subnets

Review the network configuration in `network.tf` and understand the components.

### 2. Security Configuration
Configure security groups and subnet groups:
- Create a database subnet group
- Set up security group for RDS access
- Configure inbound rules for database port
- Set up outbound rules

Review the security configuration in `security.tf`.

### 3. RDS Instance Deployment
Deploy the RDS instance with basic configuration:
- Choose appropriate instance class
- Configure storage settings
- Set up backup retention
- Enable basic monitoring
- Configure maintenance window

Review the RDS configuration in `main.tf`.

### 4. Validation Steps

#### a. Verify Network Configuration
```bash
# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=rds-vpc"

# Check Subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"

# Check Security Groups
aws ec2 describe-security-groups --filters "Name=group-name,Values=rds-sg"
```

#### b. Verify RDS Instance
```bash
# Check RDS Instance Status
aws rds describe-db-instances \
  --db-instance-identifier your-db-instance

# Check Parameter Group
aws rds describe-db-parameter-groups \
  --db-parameter-group-name your-parameter-group
```

#### c. Test Connectivity
```bash
# Get the RDS endpoint
ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier your-db-instance \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)

# Test connection using MySQL client
mysql -h $ENDPOINT -u admin -p
```

### 5. Clean Up
When you're done with the task:
```bash
# Destroy resources
terraform destroy -auto-approve
```

## Implementation Details

### 1. Network Configuration
Review `network.tf`:
```hcl
# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "rds-vpc"
  }
}

# Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "rds-private-${count.index + 1}"
  }
}
```

### 2. Security Configuration
Review `security.tf`:
```hcl
# Security Group
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 3. RDS Configuration
Review `main.tf`:
```hcl
# RDS Instance
resource "aws_db_instance" "main" {
  identifier        = "basic-mysql"
  engine            = "mysql"
  engine_version    = "8.0.28"
  instance_class    = "db.t3.medium"
  allocated_storage = 20

  db_name  = "myapp"
  username = "admin"
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  skip_final_snapshot = true

  tags = {
    Name = "basic-mysql"
  }
}
```

## Common Issues and Troubleshooting

### 1. Connectivity Issues
- Verify security group rules
- Check subnet routing
- Confirm VPC DNS settings
- Test connectivity from within VPC

### 2. Performance Issues
- Monitor CloudWatch metrics
- Check instance size
- Review storage configuration
- Analyze slow query logs

### 3. Configuration Issues
- Verify parameter group settings
- Check option group configuration
- Review maintenance window
- Validate backup settings

## Best Practices

1. Security
- Use strong passwords
- Implement proper security groups
- Enable encryption at rest
- Use SSL for connections

2. Performance
- Choose appropriate instance size
- Monitor performance metrics
- Configure proper storage
- Use parameter groups wisely

3. Maintenance
- Schedule maintenance windows
- Enable automated backups
- Monitor database logs
- Keep engine version updated

## Additional Resources

1. AWS Documentation
- [RDS User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html)
- [RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)

2. Terraform Documentation
- [RDS Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)
- [VPC Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)

3. MySQL Documentation
- [MySQL 8.0 Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/)
- [MySQL Performance Tuning](https://dev.mysql.com/doc/refman/8.0/en/optimization.html) 