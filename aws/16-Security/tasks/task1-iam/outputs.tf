output "iam_users" {
  description = "List of created IAM users"
  value = {
    for user in aws_iam_user.users : user.name => {
      arn   = user.arn
      path  = user.path
      tags  = user.tags
    }
  }
}

output "iam_groups" {
  description = "List of created IAM groups"
  value = {
    for group in aws_iam_group.groups : group.name => {
      arn  = group.arn
      path = group.path
    }
  }
}

output "password_policy" {
  description = "Current password policy settings"
  value = {
    minimum_password_length        = aws_iam_account_password_policy.strict.minimum_password_length
    require_lowercase             = aws_iam_account_password_policy.strict.require_lowercase
    require_uppercase             = aws_iam_account_password_policy.strict.require_uppercase
    require_numbers               = aws_iam_account_password_policy.strict.require_numbers
    require_symbols               = aws_iam_account_password_policy.strict.require_symbols
    allow_users_to_change_password = aws_iam_account_password_policy.strict.allow_users_to_change_password
    max_password_age              = aws_iam_account_password_policy.strict.max_password_age
    password_reuse_prevention     = aws_iam_account_password_policy.strict.password_reuse_prevention
  }
}

output "mfa_policy" {
  description = "MFA policy ARN if enabled"
  value       = var.require_mfa ? aws_iam_policy.require_mfa[0].arn : null
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group name for IAM logs if enabled"
  value       = var.enable_cloudwatch_logging ? aws_cloudwatch_log_group.iam_logs[0].name : null
}

output "cloudwatch_alarms" {
  description = "List of CloudWatch alarms if enabled"
  value = var.enable_cloudwatch_logging ? {
    root_account_usage = aws_cloudwatch_metric_alarm.root_account_usage[0].arn
    access_key_age     = aws_cloudwatch_metric_alarm.access_key_age[0].arn
  } : null
} 