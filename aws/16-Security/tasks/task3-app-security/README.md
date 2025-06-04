# Task 3: Application Security

This task focuses on implementing application-level security features while staying within Free Tier limits.

## Objectives

1. Configure WAF protection
2. Implement SSL/TLS security
3. Set up secrets management
4. Configure security headers
5. Implement monitoring and alerting
6. Deploy secure load balancer

## Prerequisites

- AWS Account with Free Tier access
- AWS CLI configured
- Terraform installed
- Domain name for SSL certificate
- Completed Tasks 1 and 2

## Architecture Overview

```plaintext
                                     ┌──────────────┐
                                     │   Internet   │
                                     └──────┬───────┘
                                            │
                                     ┌──────┴───────┐
                                     │     WAF      │
                                     └──────┬───────┘
                                            │
                                     ┌──────┴───────┐
                                     │     ALB      │
                                     │   (HTTPS)    │
                                     └──────┬───────┘
                                            │
                    ┌────────────────┬──────┴───────┬────────────────┐
                    │                │              │                │
              ┌─────┴─────┐    ┌─────┴─────┐  ┌─────┴─────┐  ┌─────┴─────┐
              │  Lambda    │    │  Secrets  │  │Certificate │  │CloudWatch │
              │  Headers   │    │  Manager  │  │  Manager   │  │  Alarms   │
              └───────────┘    └───────────┘  └───────────┘  └───────────┘
```

## Task Steps

### 1. WAF Configuration

```hcl
# Example terraform.tfvars
enable_waf = true
waf_block_rules = [
  {
    name     = "block-sql-injection"
    priority = 1
    action   = "block"
    rules    = [
      {
        type  = "SQLInjection"
        value = "MATCH"
      }
    ]
  }
]
```

### 2. SSL Certificate

```hcl
# Example terraform.tfvars
domain_name = "example.com"
alternative_names = ["*.example.com"]
```

### 3. Secrets Management

```hcl
# Example terraform.tfvars
enable_secrets_manager = true
secrets = [
  {
    name        = "db-password"
    description = "Database password"
    type        = "string"
  },
  {
    name        = "api-key"
    description = "API key"
    type        = "string"
  }
]
```

### 4. Security Headers

```hcl
# Example terraform.tfvars
security_headers = {
  hsts                    = true
  content_security_policy = true
  x_frame_options         = true
  x_content_type_options  = true
  referrer_policy        = true
}
```

### 5. Monitoring Configuration

```hcl
# Example terraform.tfvars
enable_monitoring = true
alert_email = "security@example.com"
```

## Implementation Steps

1. Clone the repository
2. Navigate to the task directory:
   ```bash
   cd aws/16-Security/tasks/task3-app-security
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

1. Verify WAF Rules:
   ```bash
   aws wafv2 get-web-acl --name secure-app-web-acl --scope REGIONAL
   ```

2. Check Certificate:
   ```bash
   aws acm list-certificates
   ```

3. Test Security Headers:
   ```bash
   curl -I https://your-domain.com
   ```

4. Verify Secrets:
   ```bash
   aws secretsmanager list-secrets
   ```

5. Check Alarms:
   ```bash
   aws cloudwatch describe-alarms
   ```

## Clean Up

To remove all created resources:
```bash
terraform destroy
```

## Best Practices Implemented

1. **WAF Protection**
   - SQL injection prevention
   - XSS protection
   - Rate limiting
   - Geo blocking

2. **SSL/TLS Security**
   - TLS 1.2+
   - Strong ciphers
   - Perfect forward secrecy
   - OCSP stapling

3. **Secrets Management**
   - Encrypted storage
   - Access control
   - Automatic rotation
   - Audit logging

4. **Security Headers**
   - HSTS
   - CSP
   - X-Frame-Options
   - X-Content-Type-Options

## Free Tier Considerations

This implementation stays within Free Tier limits by:
- Using basic WAF rules
- Minimal secrets storage
- Limited monitoring
- Basic SSL certificate
- Optimized Lambda usage

## Next Steps

After completing this task:
1. Add custom WAF rules
2. Implement API security
3. Add DDoS protection
4. Enhance monitoring
5. Implement logging

## Troubleshooting

Common issues and solutions:

1. **WAF Issues**
   - Check rule syntax
   - Verify priorities
   - Test rule sets
   - Monitor metrics

2. **Certificate Problems**
   - Verify DNS validation
   - Check domain ownership
   - Test SSL configuration
   - Monitor expiration

3. **Security Headers**
   - Validate header syntax
   - Test browser behavior
   - Check Lambda logs
   - Monitor responses

## Additional Resources

- [AWS WAF Documentation](https://docs.aws.amazon.com/waf/)
- [ACM Documentation](https://docs.aws.amazon.com/acm/)
- [Secrets Manager Documentation](https://docs.aws.amazon.com/secretsmanager/)
- [Security Headers Best Practices](https://owasp.org/www-project-secure-headers/) 