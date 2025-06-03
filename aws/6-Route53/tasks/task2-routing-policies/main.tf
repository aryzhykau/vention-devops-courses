# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create health checks for each endpoint
resource "aws_route53_health_check" "primary" {
  fqdn              = var.primary_endpoint
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"
  
  regions = var.health_check_regions
  
  tags = {
    Name = "${var.project_name}-primary-health-check"
  }
}

resource "aws_route53_health_check" "secondary" {
  fqdn              = var.secondary_endpoint
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"
  
  regions = var.health_check_regions
  
  tags = {
    Name = "${var.project_name}-secondary-health-check"
  }
}

# 1. Weighted Routing Policy
resource "aws_route53_record" "weighted_primary" {
  zone_id = var.zone_id
  name    = "weighted.${var.domain_name}"
  type    = "A"
  
  weighted_routing_policy {
    weight = 60
  }
  
  set_identifier = "primary"
  health_check_id = aws_route53_health_check.primary.id
  
  alias {
    name                   = var.primary_endpoint
    zone_id               = var.primary_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "weighted_secondary" {
  zone_id = var.zone_id
  name    = "weighted.${var.domain_name}"
  type    = "A"
  
  weighted_routing_policy {
    weight = 40
  }
  
  set_identifier = "secondary"
  health_check_id = aws_route53_health_check.secondary.id
  
  alias {
    name                   = var.secondary_endpoint
    zone_id               = var.secondary_zone_id
    evaluate_target_health = true
  }
}

# 2. Latency-based Routing Policy
resource "aws_route53_record" "latency_us_west" {
  zone_id = var.zone_id
  name    = "latency.${var.domain_name}"
  type    = "A"
  
  latency_routing_policy {
    region = "us-west-2"
  }
  
  set_identifier = "us-west-2"
  health_check_id = aws_route53_health_check.us_west.id
  
  alias {
    name                   = var.us_west_endpoint
    zone_id               = var.us_west_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "latency_us_east" {
  zone_id = var.zone_id
  name    = "latency.${var.domain_name}"
  type    = "A"
  
  latency_routing_policy {
    region = "us-east-1"
  }
  
  set_identifier = "us-east-1"
  health_check_id = aws_route53_health_check.us_east.id
  
  alias {
    name                   = var.us_east_endpoint
    zone_id               = var.us_east_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "latency_eu_west" {
  zone_id = var.zone_id
  name    = "latency.${var.domain_name}"
  type    = "A"
  
  latency_routing_policy {
    region = "eu-west-1"
  }
  
  set_identifier = "eu-west-1"
  health_check_id = aws_route53_health_check.eu_west.id
  
  alias {
    name                   = var.eu_west_endpoint
    zone_id               = var.eu_west_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "latency_ap_northeast" {
  zone_id = var.zone_id
  name    = "latency.${var.domain_name}"
  type    = "A"
  
  latency_routing_policy {
    region = "ap-northeast-1"
  }
  
  set_identifier = "ap-northeast-1"
  health_check_id = aws_route53_health_check.ap_northeast.id
  
  alias {
    name                   = var.ap_northeast_endpoint
    zone_id               = var.ap_northeast_zone_id
    evaluate_target_health = true
  }
}

# 3. Geolocation Routing Policy
resource "aws_route53_record" "geo_us" {
  zone_id = var.zone_id
  name    = "geo.${var.domain_name}"
  type    = "A"
  
  geolocation_routing_policy {
    country = "US"
  }
  
  set_identifier = "us"
  health_check_id = aws_route53_health_check.us_west.id
  
  alias {
    name                   = var.us_west_endpoint
    zone_id               = var.us_west_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "geo_eu" {
  zone_id = var.zone_id
  name    = "geo.${var.domain_name}"
  type    = "A"
  
  geolocation_routing_policy {
    continent = "EU"
  }
  
  set_identifier = "eu"
  health_check_id = aws_route53_health_check.eu_west.id
  
  alias {
    name                   = var.eu_west_endpoint
    zone_id               = var.eu_west_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "geo_asia" {
  zone_id = var.zone_id
  name    = "geo.${var.domain_name}"
  type    = "A"
  
  geolocation_routing_policy {
    continent = "AS"
  }
  
  set_identifier = "asia"
  health_check_id = aws_route53_health_check.ap_northeast.id
  
  alias {
    name                   = var.ap_northeast_endpoint
    zone_id               = var.ap_northeast_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "geo_default" {
  zone_id = var.zone_id
  name    = "geo.${var.domain_name}"
  type    = "A"
  
  geolocation_routing_policy {
    country = "*"
  }
  
  set_identifier = "default"
  health_check_id = aws_route53_health_check.us_east.id
  
  alias {
    name                   = var.us_east_endpoint
    zone_id               = var.us_east_zone_id
    evaluate_target_health = true
  }
}

# 4. Failover Routing Policy
resource "aws_route53_record" "failover_primary" {
  zone_id = var.zone_id
  name    = "failover.${var.domain_name}"
  type    = "A"
  
  failover_routing_policy {
    type = "PRIMARY"
  }
  
  set_identifier = "primary"
  health_check_id = aws_route53_health_check.primary.id
  
  alias {
    name                   = var.primary_endpoint
    zone_id               = var.primary_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "failover_secondary" {
  zone_id = var.zone_id
  name    = "failover.${var.domain_name}"
  type    = "A"
  
  failover_routing_policy {
    type = "SECONDARY"
  }
  
  set_identifier = "secondary"
  
  alias {
    name                   = var.secondary_endpoint
    zone_id               = var.secondary_zone_id
    evaluate_target_health = true
  }
}

# 5. Multi-value Answer Routing Policy
resource "aws_route53_record" "multi_1" {
  zone_id = var.zone_id
  name    = "multi.${var.domain_name}"
  type    = "A"
  
  multivalue_answer_policy = true
  set_identifier          = "multi-1"
  health_check_id         = aws_route53_health_check.primary.id
  
  records = [var.multi_endpoint_1]
  ttl     = "60"
}

resource "aws_route53_record" "multi_2" {
  zone_id = var.zone_id
  name    = "multi.${var.domain_name}"
  type    = "A"
  
  multivalue_answer_policy = true
  set_identifier          = "multi-2"
  health_check_id         = aws_route53_health_check.secondary.id
  
  records = [var.multi_endpoint_2]
  ttl     = "60"
}

resource "aws_route53_record" "multi_3" {
  zone_id = var.zone_id
  name    = "multi.${var.domain_name}"
  type    = "A"
  
  multivalue_answer_policy = true
  set_identifier          = "multi-3"
  health_check_id         = aws_route53_health_check.us_west.id
  
  records = [var.multi_endpoint_3]
  ttl     = "60"
}

# Health Checks for Regional Endpoints
resource "aws_route53_health_check" "us_west" {
  fqdn              = var.us_west_endpoint
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"
  
  regions = var.health_check_regions
  
  tags = {
    Name = "${var.project_name}-us-west-health-check"
  }
}

resource "aws_route53_health_check" "us_east" {
  fqdn              = var.us_east_endpoint
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"
  
  regions = var.health_check_regions
  
  tags = {
    Name = "${var.project_name}-us-east-health-check"
  }
}

resource "aws_route53_health_check" "eu_west" {
  fqdn              = var.eu_west_endpoint
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"
  
  regions = var.health_check_regions
  
  tags = {
    Name = "${var.project_name}-eu-west-health-check"
  }
}

resource "aws_route53_health_check" "ap_northeast" {
  fqdn              = var.ap_northeast_endpoint
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"
  
  regions = var.health_check_regions
  
  tags = {
    Name = "${var.project_name}-ap-northeast-health-check"
  }
}

# CloudWatch Alarms for Health Checks
resource "aws_cloudwatch_metric_alarm" "health_check_alarm" {
  for_each = {
    primary      = aws_route53_health_check.primary.id
    secondary    = aws_route53_health_check.secondary.id
    us_west      = aws_route53_health_check.us_west.id
    us_east      = aws_route53_health_check.us_east.id
    eu_west      = aws_route53_health_check.eu_west.id
    ap_northeast = aws_route53_health_check.ap_northeast.id
  }
  
  alarm_name          = "${var.project_name}-${each.key}-health-check-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period             = "60"
  statistic          = "Minimum"
  threshold          = "1"
  alarm_description  = "This metric monitors the health check status of ${each.key} endpoint"
  
  dimensions = {
    HealthCheckId = each.value
  }
  
  alarm_actions = [var.sns_topic_arn]
} 