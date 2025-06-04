# AWS Migration Module

## Overview
This module focuses on AWS migration strategies and implementations using AWS Free Tier compatible services. You will learn how to plan and execute different types of migrations while maintaining cost efficiency and minimizing downtime.

## Module Structure

### Task 1: Database Migration
- AWS Database Migration Service (DMS) setup
- Schema conversion using AWS SCT
- Continuous data replication
- Migration monitoring and validation
- Free Tier considerations and optimization

### Task 2: Application Migration
- Server Migration Service (SMS) configuration
- EC2 instance migration
- Application dependency mapping
- Load balancer setup
- Auto Scaling configuration

### Task 3: Storage Migration
- S3 data migration
- EBS volume migration
- File system migration
- Storage Gateway setup
- Backup and recovery configuration

## AWS Free Tier Considerations

### Database Migration
- DMS: 750 hours of t2.micro replication instance
- S3: 5GB storage for schema files
- RDS: 750 hours of t2.micro database instance
- CloudWatch: Basic monitoring metrics

### Application Migration
- EC2: t2.micro instances (750 hours)
- ELB: 750 hours of load balancer usage
- CloudWatch: Basic monitoring
- Auto Scaling: No additional charge
- VPC: No additional charge

### Storage Migration
- S3: 5GB storage
- EBS: 30GB of General Purpose (gp2) storage
- Storage Gateway: 100GB of data transfer
- Backup: 10GB of backup storage

## Prerequisites
- AWS Account with Free Tier access
- Basic understanding of AWS services
- Terraform installed locally
- AWS CLI configured

## Learning Objectives
1. Understand different AWS migration strategies
2. Implement database migrations using DMS
3. Configure application migration using SMS
4. Set up storage migration solutions
5. Monitor and validate migration processes
6. Implement cost-effective migration patterns

## Additional Resources
- [AWS Migration Hub](https://aws.amazon.com/migration-hub/)
- [AWS Database Migration Service](https://aws.amazon.com/dms/)
- [AWS Server Migration Service](https://aws.amazon.com/server-migration-service/)
- [AWS Storage Gateway](https://aws.amazon.com/storagegateway/) 