# IAM Core Concepts

## Identity Management

### Users
- Individual IAM users for people and applications
- Each user has unique credentials
- Can be assigned direct permissions or inherit from groups
- Support multiple access keys for programmatic access
- Can use console or programmatic access

### Groups
- Collections of IAM users
- Used to manage permissions for multiple users
- Users can belong to multiple groups
- Cannot be nested (groups within groups)
- Used to apply permissions to multiple users at once

### Roles
- Identity with specific permissions
- Can be assumed by users, applications, or AWS services
- Temporary credentials via AWS Security Token Service (STS)
- Common use cases:
  - Cross-account access
  - Application running on EC2
  - Federation with external identity providers

## Access Management

### Policy Types
1. Identity-based Policies
   - Attached to users, groups, or roles
   - Define allowed or denied permissions
   - Can be AWS managed, customer managed, or inline

2. Resource-based Policies
   - Attached directly to resources
   - Define who can access the resource
   - Common with S3 buckets, KMS keys, etc.

3. Permission Boundaries
   - Set maximum permissions for an entity
   - Does not grant permissions by itself
   - Used for delegation and security

4. Service Control Policies (SCPs)
   - Used in AWS Organizations
   - Apply to entire accounts or organizational units
   - Set maximum permissions for accounts

### Policy Structure
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["arn:aws:s3:::example-bucket"]
        }
    ]
}
```

## Security Features

### Authentication
1. Passwords
   - Configurable password policy
   - Minimum length and complexity
   - Password expiration
   - Password reuse prevention

2. Multi-Factor Authentication (MFA)
   - Virtual MFA devices
   - Hardware MFA devices
   - U2F security keys
   - Required for privileged actions

### Access Keys
- Used for programmatic access
- Two active access keys allowed per user
- Should be rotated regularly
- Can be disabled or deleted

### CloudTrail Integration
- Logs all API calls
- Useful for security analysis
- Compliance auditing
- Troubleshooting tool

## Advanced Concepts

### Federation
1. SAML 2.0
   - Enterprise identity federation
   - Single sign-on (SSO)
   - Integration with Active Directory

2. Web Identity Federation
   - Use of external identity providers
   - Amazon Cognito
   - Social identity providers

### Trust Relationships
- Define who can assume a role
- Used in cross-account access
- Essential for federation
- Can include conditions

### Session Policies
- Temporary policies for assumed roles
- Further restrict permissions
- Cannot expand permissions
- Used in temporary credentials 