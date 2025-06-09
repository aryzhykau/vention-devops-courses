# Task 1: Basic IAM Setup

This task demonstrates setting up basic IAM configurations using Terraform.

## Objectives
1. Create an IAM group for developers
2. Create multiple IAM users and add them to the group
3. Set up a strict password policy
4. Configure MFA requirements
5. Implement access key rotation

## Prerequisites
- AWS account with administrative access
- Terraform installed
- AWS CLI configured

## Implementation Steps

### 1. Provider Configuration
The AWS provider is configured for the us-west-2 region. Modify the region as needed.

### 2. IAM Group and Users
- Creates a developers group
- Creates 3 IAM users with appropriate tags
- Adds users to the developers group

### 3. Password Policy
Implements a strict password policy with:
- 12 character minimum length
- Requires uppercase, lowercase, numbers, and symbols
- 90-day password expiration
- 24 password reuse prevention

### 4. MFA Configuration
- Enables MFA requirement for the developers group
- Implements policy to deny access without MFA
- Allows users to manage their own MFA devices

### 5. Access Key Management
- Creates access keys for users
- Sets up CloudWatch event rule for key rotation
- Configures SNS notifications for key rotation

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

## Cleanup

To remove all resources:
```bash
terraform destroy
```

## Additional Notes
- Remember to enable MFA for all users after creation
- Regularly review and rotate access keys
- Monitor CloudWatch events for security compliance 