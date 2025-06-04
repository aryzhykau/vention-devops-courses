# Task 2: RDS High Availability Setup

## Overview
This task guides you through setting up a highly available RDS deployment using Multi-AZ configuration and Read Replicas. You'll learn how to implement disaster recovery, automatic failover, and read scaling for your database infrastructure.

## Objectives
1. Set up Multi-AZ RDS deployment
2. Configure Read Replicas
3. Implement automatic failover
4. Set up backup and recovery
5. Test disaster recovery scenarios

## Prerequisites
- Completion of Task 1: Basic RDS Setup
- AWS CLI configured with appropriate permissions
- Terraform installed (version 1.0.0 or higher)
- Basic understanding of database replication
- MySQL client installed locally

## Steps

### 1. Multi-AZ Configuration
Set up a Multi-AZ RDS deployment:
- Enable Multi-AZ deployment
- Configure synchronous replication
- Set up automatic failover
- Configure maintenance windows

Review the Multi-AZ configuration in `main.tf`.

### 2. Read Replica Setup
Configure Read Replicas for read scaling:
- Create Read Replicas
- Configure asynchronous replication
- Set up monitoring
- Configure promotion tiers

Review the Read Replica configuration in `replicas.tf`.

### 3. Backup Configuration
Set up comprehensive backup strategy:
- Configure automated backups
- Set up manual snapshots
- Configure cross-region replication
- Set retention policies

Review the backup configuration in `backup.tf`.

### 4. Validation Steps

#### a. Verify Multi-AZ Setup
```bash
# Check Multi-AZ configuration
aws rds describe-db-instances \
  --db-instance-identifier your-db-instance \
  --query 'DBInstances[0].MultiAZ'

# List available AZs
aws rds describe-db-instances \
  --db-instance-identifier your-db-instance \
  --query 'DBInstances[0].AvailabilityZone'
```

#### b. Verify Read Replicas
```bash
# List Read Replicas
aws rds describe-db-instances \
  --query 'DBInstances[?ReadReplicaSourceDBInstanceIdentifier!=`null`]'

# Check replication status
aws rds describe-db-instances \
  --db-instance-identifier your-replica \
  --query 'DBInstances[0].StatusInfos'
```

#### c. Test Failover
```bash
# Initiate failover
aws rds reboot-db-instance \
  --db-instance-identifier your-db-instance \
  --force-failover

# Monitor failover status
aws rds describe-events \
  --source-type db-instance \
  --source-identifier your-db-instance
```

### 5. Clean Up
When you're done with the task:
```bash
# Destroy resources
terraform destroy -auto-approve
```

## Implementation Details

### 1. Multi-AZ Configuration
Review `main.tf`:
```hcl
# Multi-AZ RDS Instance
resource "aws_db_instance" "main" {
  identifier        = "ha-mysql"
  engine            = "mysql"
  engine_version    = "8.0.28"
  instance_class    = "db.r5.large"
  allocated_storage = 100

  multi_az               = true
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  deletion_protection = true
}
```

### 2. Read Replica Configuration
Review `replicas.tf`:
```hcl
# Read Replica
resource "aws_db_instance" "replica" {
  identifier     = "ha-mysql-replica"
  instance_class = "db.r5.large"
  replicate_source_db = aws_db_instance.main.id

  auto_minor_version_upgrade = true
  multi_az                  = true
  vpc_security_group_ids    = [aws_security_group.rds.id]
}
```

### 3. Backup Configuration
Review `backup.tf`:
```hcl
# Snapshot Configuration
resource "aws_db_snapshot" "backup" {
  db_instance_identifier = aws_db_instance.main.id
  db_snapshot_identifier = "ha-mysql-snapshot"
}
```

## Common Issues and Troubleshooting

### 1. Replication Issues
- Monitor replication lag
- Check network connectivity
- Verify instance capacity
- Review error logs

### 2. Failover Problems
- Check DNS resolution
- Verify security groups
- Monitor event logs
- Test application retry logic

### 3. Performance Issues
- Monitor CloudWatch metrics
- Check instance sizing
- Review connection patterns
- Analyze query performance

## Best Practices

1. High Availability
- Use Multi-AZ deployment
- Configure multiple Read Replicas
- Implement proper monitoring
- Test failover regularly

2. Backup Strategy
- Enable automated backups
- Take regular snapshots
- Test recovery procedures
- Monitor backup success

3. Performance
- Monitor replication lag
- Balance read workloads
- Configure proper instance sizes
- Use appropriate storage types

## Additional Resources

1. AWS Documentation
- [RDS Multi-AZ Deployments](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html)
- [RDS Read Replicas](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html)
- [RDS Backup and Restore](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_CommonTasks.BackupRestore.html)

2. Terraform Documentation
- [RDS Instance Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)
- [RDS Snapshot Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_snapshot)

3. MySQL Documentation
- [MySQL Replication](https://dev.mysql.com/doc/refman/8.0/en/replication.html)
- [High Availability](https://dev.mysql.com/doc/refman/8.0/en/ha-overview.html) 