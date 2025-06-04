# IAM Best Practices

## Security Best Practices

### 1. Root Account Protection
- Lock away root user access keys
- Enable MFA for root account
- Use root only for initial setup and rare administrative tasks
- Create separate admin users for day-to-day management

### 2. User Management
- Create individual users instead of sharing credentials
- Use groups to assign permissions
- Implement strong password policy
- Rotate credentials regularly
- Enable MFA for privileged users

### 3. Permission Management
- Follow principle of least privilege
- Start with minimum permissions and grant as needed
- Use permission boundaries for delegation
- Regularly review and remove unused permissions
- Use AWS managed policies when possible

### 4. Role Usage
- Use roles for applications running on AWS services
- Implement cross-account roles instead of sharing credentials
- Use roles for federated users
- Regularly review and update trust relationships
- Set appropriate maximum session duration

## Operational Best Practices

### 1. Access Key Management
```bash
# List access keys
aws iam list-access-keys

# Create new access key
aws iam create-access-key

# Delete old access key
aws iam delete-access-key
```

### 2. Regular Auditing
- Review IAM usage regularly
- Use AWS IAM Access Analyzer
- Monitor CloudTrail logs
- Set up alerts for suspicious activities
- Document permission changes

### 3. Policy Management
- Use policy conditions to increase security
- Implement tags for resource-based access control
- Version control your custom policies
- Test policies in sandbox environment
- Use policy simulator before deployment

## Compliance Best Practices

### 1. Documentation
- Maintain up-to-date access documentation
- Document approval processes
- Keep track of policy versions
- Document emergency access procedures
- Maintain audit logs

### 2. Access Reviews
- Conduct regular access reviews
- Remove unnecessary permissions
- Update access based on job changes
- Review service-linked roles
- Audit federation setup

### 3. Monitoring and Logging
- Enable CloudTrail in all regions
- Set up log file validation
- Configure CloudWatch alarms
- Monitor API activity
- Set up automated compliance checks

## Security Tools and Features

### 1. IAM Access Analyzer
- Identify resources shared with external entities
- Review findings regularly
- Set up automated remediation
- Monitor changes in resource access
- Generate reports for compliance

### 2. Credential Reports
```bash
# Generate credential report
aws iam generate-credential-report

# Get credential report
aws iam get-credential-report
```

### 3. Policy Simulator
- Test policy changes before implementation
- Troubleshoot permission issues
- Validate custom policies
- Check resource access
- Train new administrators

## Emergency Procedures

### 1. Access Key Compromise
1. Immediately disable compromised keys
2. Audit usage of compromised keys
3. Rotate all potentially affected secrets
4. Review and update policies
5. Document incident and response

### 2. Root Account Recovery
- Document recovery procedures
- Store recovery codes securely
- Test recovery process regularly
- Train backup administrators
- Maintain emergency contacts

## Implementation Examples

### 1. Group Structure Example
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:ChangePassword",
                "iam:GetUser",
                "iam:ListMFADevices"
            ],
            "Resource": ["arn:aws:iam::*:user/${aws:username}"]
        }
    ]
}
```

### 2. Permission Boundary Example
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "cloudwatch:*"
            ],
            "Resource": "*"
        }
    ]
}
``` 