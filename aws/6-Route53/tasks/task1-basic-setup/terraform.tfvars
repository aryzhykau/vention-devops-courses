aws_region = "us-west-2"
domain_name = "example.com"
environment = "Production"
project_name = "my-awesome-project"

# These values should be replaced with actual values from your AWS resources
alb_dns_name = "my-alb-123456789.us-west-2.elb.amazonaws.com"
alb_zone_id = "Z3DZXE0EXAMPLE"

mx_records = [
  "10 mail1.example.com",
  "20 mail2.example.com",
  "30 mail3.example.com"
]

txt_records = [
  "v=spf1 include:_spf.example.com include:_spf.google.com ~all",
  "google-site-verification=example123456"
]

sns_topic_arn = "arn:aws:sns:us-west-2:123456789012:route53-alerts"
query_threshold = 10000

s3_website_domain = "my-static-website.s3-website-us-west-2.amazonaws.com"
s3_website_zone_id = "Z3BJ6K6RIION7M"

cloudfront_domain_name = "d1234abcd.cloudfront.net"
cloudfront_hosted_zone_id = "Z2FDTNDATAQYW2"

api_gateway_domain_name = "api123.execute-api.us-west-2.amazonaws.com"
api_gateway_zone_id = "Z1UJRXOUMOOFQ8" 