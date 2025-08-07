output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "security_group_id" {
  value = tolist(aws_instance.this.vpc_security_group_ids)[0]
}

