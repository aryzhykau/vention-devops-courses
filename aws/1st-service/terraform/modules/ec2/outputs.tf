output "instance_id" {
  value = aws_instance.app.id
}

output "public_ip" {
  value = aws_instance.app.public_ip
}

output "security_group_id" {
  value = tolist(aws_instance.app.vpc_security_group_ids)[0]
}

