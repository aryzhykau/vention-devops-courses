output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "rds_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "rds_username" {
  description = "The master username for the RDS instance"
  value       = aws_db_instance.main.username
}

output "rds_database_name" {
  description = "The name of the default database"
  value       = aws_db_instance.main.db_name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "security_group_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "parameter_group_name" {
  description = "The name of the DB parameter group"
  value       = aws_db_parameter_group.main.name
}

output "subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "monitoring_role_arn" {
  description = "The ARN of the RDS monitoring IAM role"
  value       = aws_iam_role.rds_monitoring.arn
}

output "cloudwatch_cpu_alarm_arn" {
  description = "The ARN of the CloudWatch CPU alarm"
  value       = aws_cloudwatch_metric_alarm.database_cpu.arn
}

output "cloudwatch_memory_alarm_arn" {
  description = "The ARN of the CloudWatch memory alarm"
  value       = aws_cloudwatch_metric_alarm.database_memory.arn
}

output "cloudwatch_storage_alarm_arn" {
  description = "The ARN of the CloudWatch storage alarm"
  value       = aws_cloudwatch_metric_alarm.database_storage.arn
} 