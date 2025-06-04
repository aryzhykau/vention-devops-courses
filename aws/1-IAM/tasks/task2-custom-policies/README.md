# Task 2: Custom IAM Policies

## Overview
This task focuses on creating and managing custom IAM policies following the principle of least privilege. You will learn how to create different types of policies, implement permission boundaries, and use policy conditions.

## Objectives
1. Create least privilege policies
2. Implement resource-based policies
3. Set up permission boundaries
4. Configure policy conditions
5. Create and manage different policy types

## Prerequisites
- AWS account with IAM full access
- AWS CLI configured
- Terraform installed
- Basic understanding of JSON policy syntax

## Implementation Steps

### 1. Least Privilege Policies
- Create S3 bucket access policy
- Configure EC2 instance management policy
- Set up RDS database access policy
- Implement CloudWatch logging policy

### 2. Resource-Based Policies
- Create S3 bucket policy
- Configure KMS key policy
- Set up SQS queue policy
- Implement Lambda function policy

### 3. Permission Boundaries
- Create developer boundary
- Set up operator boundary
- Configure service-specific boundaries
- Implement project-based boundaries

### 4. Policy Conditions
- Implement IP-based restrictions
- Configure time-based access
- Set up MFA requirements
- Add tag-based conditions

### 5. Policy Management
- Create managed policies
- Implement inline policies
- Set up policy versioning
- Configure policy attachments

## Validation Criteria
- [ ] Policies follow least privilege principle
- [ ] Resource policies properly configured
- [ ] Permission boundaries working
- [ ] Conditions effectively restricting access
- [ ] Policy management organized

## Additional Resources
- [IAM Policy Types](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html)
- [IAM Policy Elements](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements.html)
- [Permission Boundaries](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html) 