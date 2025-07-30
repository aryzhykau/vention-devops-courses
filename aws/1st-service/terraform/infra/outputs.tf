output "bucket_name" {
  value = module.s3.bucket_name
}

output "bucket_arn" {
  value = module.s3.bucket_arn
}

output "ec2_role_arn" {
  value = module.iam.ec2_role_arn
}

output "instance_profile_name" {
  value = module.iam.instance_profile_name
}

output "alb_arn" {
  value = module.loadbalancer.alb_arn
}

output "alb_listener_arn" {
  value = module.loadbalancer.alb_listener_arn
}

output "alb_dns_name" {
  value = module.loadbalancer.alb_dns_name
}

output "vpc_id" {
  value = data.aws_vpc.existing.id
}

output "public_subnet_ids" {
  value = [data.aws_subnet.existing.id]
}

