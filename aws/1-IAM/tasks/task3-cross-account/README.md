# Task 3: Cross-Account Access

## Overview
This task focuses on implementing secure cross-account access in AWS using IAM roles and policies. You will learn how to set up and manage cross-account permissions using AWS Security Token Service (STS) and implement proper security controls.

## Objectives
1. Set up cross-account roles
2. Configure trust relationships
3. Implement STS assume role functionality
4. Set up external ID security
5. Configure role session policies

## Prerequisites
- Two AWS accounts (source and target)
- AWS CLI configured with appropriate credentials
- Terraform installed
- Basic understanding of AWS STS and IAM roles

## Implementation Steps

### 1. Cross-Account Role Setup
- Create IAM role in target account
- Configure trust relationship with source account
- Set up appropriate permissions
- Implement role policies

### 2. Trust Relationships
- Configure trust policy for source account
- Set up external ID requirement
- Implement condition keys
- Configure MFA requirements

### 3. STS Implementation
- Set up AWS STS assume role
- Configure role session duration
- Implement role session tagging
- Set up session policies

### 4. External ID Security
- Generate and configure external ID
- Implement external ID validation
- Set up monitoring for assume role events
- Configure alerts for suspicious activities

### 5. Session Management
- Configure session duration limits
- Implement session tagging
- Set up session monitoring
- Configure session policy restrictions

## Validation Criteria
- [ ] Cross-account roles properly configured
- [ ] Trust relationships working correctly
- [ ] STS assume role functioning
- [ ] External ID validation working
- [ ] Session policies enforced

## Security Considerations
- Always use external IDs for cross-account access
- Implement least privilege access
- Enable CloudTrail logging
- Set up monitoring and alerting
- Regular rotation of credentials

## Additional Resources
- [AWS Cross-Account Access](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html)
- [AWS STS Documentation](https://docs.aws.amazon.com/STS/latest/APIReference/welcome.html)
- [External ID Security](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html) 