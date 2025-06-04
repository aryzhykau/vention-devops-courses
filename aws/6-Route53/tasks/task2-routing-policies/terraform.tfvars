aws_region = "us-west-2"
project_name = "my-awesome-project"
domain_name = "example.com"
zone_id = "Z1234567890ABC"

health_check_regions = [
  "us-west-2",
  "us-east-1",
  "eu-west-1"
]

# Primary/Secondary Endpoints
primary_endpoint = "primary-alb.us-west-2.elb.amazonaws.com"
primary_zone_id = "Z3DZXE0EXAMPLE1"

secondary_endpoint = "secondary-alb.us-east-1.elb.amazonaws.com"
secondary_zone_id = "Z3DZXE0EXAMPLE2"

# Regional Endpoints
us_west_endpoint = "usw-alb.us-west-2.elb.amazonaws.com"
us_west_zone_id = "Z3DZXE0EXAMPLE3"

us_east_endpoint = "use-alb.us-east-1.elb.amazonaws.com"
us_east_zone_id = "Z3DZXE0EXAMPLE4"

eu_west_endpoint = "euw-alb.eu-west-1.elb.amazonaws.com"
eu_west_zone_id = "Z3DZXE0EXAMPLE5"

ap_northeast_endpoint = "apn-alb.ap-northeast-1.elb.amazonaws.com"
ap_northeast_zone_id = "Z3DZXE0EXAMPLE6"

# Multi-value Answer Endpoints
multi_endpoint_1 = "10.0.1.10"
multi_endpoint_2 = "10.0.2.20"
multi_endpoint_3 = "10.0.3.30"

# Monitoring
sns_topic_arn = "arn:aws:sns:us-west-2:123456789012:route53-alerts" 