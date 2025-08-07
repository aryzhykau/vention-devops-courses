output "db_endpoint" {
  value       = aws_db_instance.this.address
  description = "Database endpoint"
}

output "db_port" {
  value       = aws_db_instance.this.port
  description = "Database port"
}

