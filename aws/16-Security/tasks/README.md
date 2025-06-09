# AWS Security Practical Tasks

## Task 1: IAM Security Setup
Create a Terraform configuration to set up a secure IAM environment:
- Create an IAM group for developers
- Create IAM users and add them to the group
- Implement password policy
- Create custom IAM policies with least privilege access
- Enable MFA for users

[View Solution](./task1-iam-security/)

## Task 2: VPC Security Implementation
Set up a secure VPC environment using Terraform:
- Create VPC with public and private subnets
- Implement Network ACLs with strict rules
- Configure Security Groups for different tiers
- Set up VPC Flow Logs
- Implement VPC Endpoints for AWS services

[View Solution](./task2-vpc-security/)

## Task 3: Web Application Security
Implement security for a web application:
- Set up WAF with custom rules
- Configure AWS Shield
- Implement SSL/TLS using ACM
- Set up CloudFront with security headers
- Enable GuardDuty for threat detection

[View Solution](./task3-web-security/)

## Task 4: Data Protection
Configure data protection mechanisms:
- Set up KMS encryption
- Implement S3 bucket policies and encryption
- Configure Secrets Manager
- Set up CloudTrail with encrypted logs
- Implement backup policies with encryption

[View Solution](./task4-data-protection/)

## Task 5: Security Monitoring
Create a comprehensive security monitoring solution:
- Set up CloudWatch alarms for security events
- Configure Security Hub
- Implement AWS Config rules
- Set up GuardDuty with custom findings
- Create SNS notifications for security alerts

[View Solution](./task5-security-monitoring/) 