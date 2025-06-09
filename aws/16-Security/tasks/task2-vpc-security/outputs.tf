output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "nat_gateway_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "vpc_flow_logs_group" {
  description = "Name of the VPC Flow Logs CloudWatch group"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.flow_logs[0].name : null
}

output "vpc_endpoints" {
  description = "List of VPC Endpoints created"
  value = {
    s3        = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
    dynamodb  = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].id : null
  }
}

output "network_acls" {
  description = "Network ACL configurations"
  value = {
    id           = aws_network_acl.main.id
    subnet_count = length(concat(aws_subnet.public[*].id, aws_subnet.private[*].id))
  }
}

output "route_tables" {
  description = "Route table information"
  value = {
    public  = aws_route_table.public.id
    private = aws_route_table.private.id
  }
}

output "monitoring_info" {
  description = "Monitoring configuration details"
  value = var.enable_monitoring ? {
    network_alarm = aws_cloudwatch_metric_alarm.network_in[0].arn
  } : null
}

output "vpc_cidr_range" {
  description = "CIDR range of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = data.aws_availability_zones.available.names
} 