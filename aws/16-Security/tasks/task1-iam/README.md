# Task 1: IAM Fundamentals

This task focuses on implementing AWS Identity and Access Management (IAM) best practices while staying within Free Tier limits.

## Objectives

1. Set up secure IAM users and groups
2. Implement strong password policies
3. Enable and configure MFA
4. Set up access key rotation
5. Configure basic security monitoring

## Prerequisites

- AWS Account with Free Tier access
- AWS CLI configured
- Terraform installed
- Basic understanding of IAM concepts

## Task Steps

### 1. Configure Password Policy

```hcl
# Example terraform.tfvars
password_policy = {
  minimum_password_length        = 12
  require_lowercase             = true
  require_uppercase             = true
  require_numbers               = true
  require_symbols               = true
  allow_users_to_change_password = true
  max_password_age              = 90
  password_reuse_prevention     = 24
}
```

### 2. Create IAM Groups

```hcl
# Example terraform.tfvars
iam_groups = [
  {
    name        = "developers"
    path        = "/developers/"
    policies    = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    description = "Developer group with PowerUser access"
  },
  {
    name        = "readonly"
    path        = "/readonly/"
    policies    = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    description = "Read-only access group"
  }
]
```

### 3. Create IAM Users

```hcl
# Example terraform.tfvars
iam_users = [
  {
    username = "developer1"
    groups   = ["developers"]
    tags     = {
      Department = "Engineering"
      Role      = "Developer"
    }
  },
  {
    username = "analyst1"
    groups   = ["readonly"]
    tags     = {
      Department = "Analytics"
      Role      = "Analyst"
    }
  }
]
```

### 4. Enable MFA

```hcl
# Example terraform.tfvars
require_mfa = true
```

### 5. Configure CloudWatch Monitoring

```hcl
# Example terraform.tfvars
enable_cloudwatch_logging = true
access_key_rotation_days = 90
```

## Implementation Steps

1. Clone the repository
2. Navigate to the task directory:
   ```bash
   cd aws/16-Security/tasks/task1-iam
   ```

3. Create a `terraform.tfvars` file with your configurations

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Review the plan:
   ```bash
   terraform plan
   ```

6. Apply the configuration:
   ```bash
   terraform apply
   ```

## Validation Steps

1. Verify IAM Users:
   ```bash
   aws iam list-users
   ```

2. Check Group Memberships:
   ```bash
   aws iam list-groups
   ```

3. Verify Password Policy:
   ```bash
   aws iam get-account-password-policy
   ```

4. Test MFA Enforcement:
   - Try to access AWS services without MFA
   - Configure MFA for a test user
   - Verify access is blocked without MFA

5. Check CloudWatch Alarms:
   - View alarms in CloudWatch console
   - Verify metrics are being collected
   - Test alarm notifications

## Clean Up

To remove all created resources:
```bash
terraform destroy
```

## Best Practices Implemented

1. **Password Policy**
   - Minimum 12 characters
   - Complex password requirements
   - Password expiration
   - Password reuse prevention

2. **Access Management**
   - Group-based access control
   - Principle of least privilege
   - Tag-based organization
   - MFA enforcement

3. **Monitoring**
   - CloudWatch logging
   - Access key age monitoring
   - Root account usage alerts
   - Regular security checks

4. **Security**
   - MFA requirement
   - Access key rotation
   - Audit logging
   - Security alerts

## Free Tier Considerations

This implementation stays within Free Tier limits by:
- Using only IAM (always free)
- Minimal CloudWatch metrics
- Basic logging configuration
- Limited number of alarms

## Next Steps

After completing this task:
1. Review IAM best practices
2. Implement custom policies
3. Set up cross-account access
4. Configure federation
5. Implement automated rotation

## Troubleshooting

Common issues and solutions:

1. **Policy Attachment Failures**
   - Verify policy ARNs
   - Check permissions
   - Review error messages

2. **MFA Issues**
   - Verify device setup
   - Check policy syntax
   - Test with test user

3. **CloudWatch Alerts**
   - Check metric availability
   - Verify alarm configuration
   - Test notification delivery

## Additional Resources

- [AWS IAM Documentation](https://docs.aws.amazon.com/iam/)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [CloudWatch Documentation](https://docs.aws.amazon.com/cloudwatch/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) 