output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.dms_vpc.id
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = aws_subnet.dms_subnet[*].id
}

output "dms_replication_instance_arn" {
  description = "ARN of the DMS replication instance"
  value       = aws_dms_replication_instance.dms.replication_instance_arn
}

output "dms_subnet_group_id" {
  description = "ID of the DMS subnet group"
  value       = aws_dms_replication_subnet_group.dms.id
}

output "schema_storage_bucket" {
  description = "Name of the S3 bucket for schema storage"
  value       = aws_s3_bucket.schema_storage.id
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.dms.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = aws_sns_topic.dms_notifications.arn
} 