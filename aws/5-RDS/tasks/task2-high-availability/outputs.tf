output "primary_instance_endpoint" {
  description = "The endpoint of the primary RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "primary_instance_arn" {
  description = "The ARN of the primary RDS instance"
  value       = aws_db_instance.main.arn
}

output "read_replica_endpoint" {
  description = "The endpoint of the read replica"
  value       = aws_db_instance.replica.endpoint
}

output "cross_region_replica_endpoint" {
  description = "The endpoint of the cross-region read replica"
  value       = aws_db_instance.cross_region_replica.endpoint
}

output "primary_vpc_id" {
  description = "The ID of the primary VPC"
  value       = aws_vpc.main.id
}

output "dr_vpc_id" {
  description = "The ID of the DR VPC"
  value       = aws_vpc.dr.id
}

output "primary_private_subnet_ids" {
  description = "The IDs of the private subnets in the primary region"
  value       = aws_subnet.private[*].id
}

output "dr_private_subnet_ids" {
  description = "The IDs of the private subnets in the DR region"
  value       = aws_subnet.private_dr[*].id
}

output "primary_security_group_id" {
  description = "The ID of the primary RDS security group"
  value       = aws_security_group.rds.id
}

output "dr_security_group_id" {
  description = "The ID of the DR RDS security group"
  value       = aws_security_group.rds_dr.id
}

output "primary_parameter_group_name" {
  description = "The name of the primary DB parameter group"
  value       = aws_db_parameter_group.main.name
}

output "replica_parameter_group_name" {
  description = "The name of the replica DB parameter group"
  value       = aws_db_parameter_group.replica.name
}

output "dr_parameter_group_name" {
  description = "The name of the DR DB parameter group"
  value       = aws_db_parameter_group.replica_dr.name
}

output "primary_option_group_name" {
  description = "The name of the primary DB option group"
  value       = aws_db_option_group.main.name
}

output "dr_option_group_name" {
  description = "The name of the DR DB option group"
  value       = aws_db_option_group.main_dr.name
}

output "primary_kms_key_arn" {
  description = "The ARN of the primary KMS key"
  value       = aws_kms_key.rds.arn
}

output "dr_kms_key_arn" {
  description = "The ARN of the DR KMS key"
  value       = aws_kms_key.rds_dr.arn
}

output "primary_monitoring_role_arn" {
  description = "The ARN of the primary RDS monitoring IAM role"
  value       = aws_iam_role.rds_monitoring.arn
}

output "dr_monitoring_role_arn" {
  description = "The ARN of the DR RDS monitoring IAM role"
  value       = aws_iam_role.rds_monitoring_dr.arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for RDS events"
  value       = aws_sns_topic.rds_events.arn
}

output "cloudwatch_alarms" {
  description = "The ARNs of the CloudWatch alarms"
  value = {
    replica_lag        = aws_cloudwatch_metric_alarm.replica_lag.arn
    cpu_utilization   = aws_cloudwatch_metric_alarm.cpu_utilization.arn
    free_storage      = aws_cloudwatch_metric_alarm.free_storage_space.arn
    dr_replica_lag    = aws_cloudwatch_metric_alarm.replica_lag_dr.arn
  }
}

output "event_subscription_arn" {
  description = "The ARN of the RDS event subscription"
  value       = aws_db_event_subscription.main.arn
} 