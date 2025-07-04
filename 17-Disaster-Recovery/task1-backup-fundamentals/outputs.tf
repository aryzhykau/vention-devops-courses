output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "s3_bucket" {
  value = module.s3.bucket_name
}

output "cloudfront_domain" {
  value = module.cloudfront.distribution_domain
}
