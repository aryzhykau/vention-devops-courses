output "nlb_id" {
  description = "ID of the Network Load Balancer"
  value       = aws_lb.network.id
}

output "nlb_arn" {
  description = "ARN of the Network Load Balancer"
  value       = aws_lb.network.arn
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = aws_lb.network.dns_name
}

output "nlb_zone_id" {
  description = "Route53 zone ID of the Network Load Balancer"
  value       = aws_lb.network.zone_id
}

output "target_groups" {
  description = "Map of target groups created and their attributes"
  value = {
    tcp = {
      arn  = aws_lb_target_group.tcp.arn
      name = aws_lb_target_group.tcp.name
      id   = aws_lb_target_group.tcp.id
    }
    udp = {
      arn  = aws_lb_target_group.udp.arn
      name = aws_lb_target_group.udp.name
      id   = aws_lb_target_group.udp.id
    }
    tls = {
      arn  = aws_lb_target_group.tls.arn
      name = aws_lb_target_group.tls.name
      id   = aws_lb_target_group.tls.id
    }
  }
}

output "listeners" {
  description = "Map of listeners created and their ARNs"
  value = {
    tcp = aws_lb_listener.tcp.arn
    udp = aws_lb_listener.udp.arn
    tls = aws_lb_listener.tls.arn
  }
}

output "elastic_ips" {
  description = "Map of Elastic IPs allocated for the NLB"
  value = {
    for subnet_id, eip in aws_eip.nlb : subnet_id => {
      id         = eip.id
      public_ip  = eip.public_ip
      private_ip = eip.private_ip
    }
  }
}

output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarms created"
  value = {
    unhealthy_hosts = {
      for k, v in aws_cloudwatch_metric_alarm.unhealthy_hosts : k => v.arn
    }
    tcp_reset = aws_cloudwatch_metric_alarm.tcp_reset.arn
    tls_error = aws_cloudwatch_metric_alarm.tls_error.arn
  }
}

output "route53_record" {
  description = "Details of the Route53 record created for the NLB"
  value = var.create_dns_record ? {
    name    = aws_route53_record.nlb[0].name
    zone_id = aws_route53_record.nlb[0].zone_id
    fqdn    = aws_route53_record.nlb[0].fqdn
  } : null
} 