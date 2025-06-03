output "weighted_routing_records" {
  description = "Details of weighted routing records"
  value = {
    primary = {
      fqdn   = aws_route53_record.weighted_primary.fqdn
      weight = "60"
    }
    secondary = {
      fqdn   = aws_route53_record.weighted_secondary.fqdn
      weight = "40"
    }
  }
}

output "latency_routing_records" {
  description = "Details of latency-based routing records"
  value = {
    us_west = {
      fqdn   = aws_route53_record.latency_us_west.fqdn
      region = "us-west-2"
    }
    us_east = {
      fqdn   = aws_route53_record.latency_us_east.fqdn
      region = "us-east-1"
    }
    eu_west = {
      fqdn   = aws_route53_record.latency_eu_west.fqdn
      region = "eu-west-1"
    }
    ap_northeast = {
      fqdn   = aws_route53_record.latency_ap_northeast.fqdn
      region = "ap-northeast-1"
    }
  }
}

output "geolocation_routing_records" {
  description = "Details of geolocation routing records"
  value = {
    us = {
      fqdn    = aws_route53_record.geo_us.fqdn
      country = "US"
    }
    eu = {
      fqdn      = aws_route53_record.geo_eu.fqdn
      continent = "EU"
    }
    asia = {
      fqdn      = aws_route53_record.geo_asia.fqdn
      continent = "AS"
    }
    default = {
      fqdn    = aws_route53_record.geo_default.fqdn
      country = "*"
    }
  }
}

output "failover_routing_records" {
  description = "Details of failover routing records"
  value = {
    primary = {
      fqdn = aws_route53_record.failover_primary.fqdn
      type = "PRIMARY"
    }
    secondary = {
      fqdn = aws_route53_record.failover_secondary.fqdn
      type = "SECONDARY"
    }
  }
}

output "multivalue_routing_records" {
  description = "Details of multi-value answer routing records"
  value = {
    endpoint_1 = {
      fqdn = aws_route53_record.multi_1.fqdn
      ip   = var.multi_endpoint_1
    }
    endpoint_2 = {
      fqdn = aws_route53_record.multi_2.fqdn
      ip   = var.multi_endpoint_2
    }
    endpoint_3 = {
      fqdn = aws_route53_record.multi_3.fqdn
      ip   = var.multi_endpoint_3
    }
  }
}

output "health_check_ids" {
  description = "IDs of all health checks"
  value = {
    primary      = aws_route53_health_check.primary.id
    secondary    = aws_route53_health_check.secondary.id
    us_west      = aws_route53_health_check.us_west.id
    us_east      = aws_route53_health_check.us_east.id
    eu_west      = aws_route53_health_check.eu_west.id
    ap_northeast = aws_route53_health_check.ap_northeast.id
  }
}

output "cloudwatch_alarm_arns" {
  description = "ARNs of CloudWatch alarms for health checks"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.health_check_alarm : k => v.arn
  }
} 