# Amazon Route53 Core Concepts

## DNS (Domain Name System)

DNS is a hierarchical distributed naming system that translates human-readable domain names into IP addresses. Key concepts:

- **Domain Names**: Hierarchical names (e.g., example.com)
- **DNS Resolution**: Process of converting domain names to IP addresses
- **DNS Records**: Different types of records storing domain information
- **TTL (Time To Live)**: Duration for which DNS records are cached

## Hosted Zones

A hosted zone is a container for DNS records for a domain.

### Public Hosted Zones
- Determine how traffic is routed on the internet
- Accessible from the public internet
- Used for public-facing resources

Example:
```hcl
resource "aws_route53_zone" "public" {
  name = "example.com"
  
  tags = {
    Environment = "Production"
  }
}
```

### Private Hosted Zones
- Route traffic within one or more VPCs
- Not accessible from the public internet
- Used for internal resources

Example:
```hcl
resource "aws_route53_zone" "private" {
  name = "internal.example.com"
  
  vpc {
    vpc_id = aws_vpc.main.id
  }
  
  tags = {
    Environment = "Production"
  }
}
```

## Record Types

### A Record (Address Record)
- Maps domain name to IPv4 address
```hcl
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.example.com"
  type    = "A"
  ttl     = "300"
  records = ["192.0.2.1"]
}
```

### AAAA Record
- Maps domain name to IPv6 address
```hcl
resource "aws_route53_record" "www_ipv6" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.example.com"
  type    = "AAAA"
  ttl     = "300"
  records = ["2001:0db8:85a3:0000:0000:8a2e:0370:7334"]
}
```

### CNAME Record (Canonical Name)
- Maps one domain name to another
```hcl
resource "aws_route53_record" "blog" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "blog.example.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["www.example.com"]
}
```

### MX Record (Mail Exchange)
- Specifies mail servers for the domain
```hcl
resource "aws_route53_record" "mail" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "example.com"
  type    = "MX"
  ttl     = "300"
  records = [
    "10 mail1.example.com",
    "20 mail2.example.com"
  ]
}
```

### TXT Record
- Stores text information for various purposes
```hcl
resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "example.com"
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 include:_spf.example.com ~all"]
}
```

## Routing Policies

### Simple Routing
- Basic routing to a single resource
```hcl
resource "aws_route53_record" "simple" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "simple.example.com"
  type    = "A"
  ttl     = "300"
  records = ["192.0.2.1"]
}
```

### Weighted Routing
- Routes traffic based on assigned weights
```hcl
resource "aws_route53_record" "weighted" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "weighted.example.com"
  type    = "A"
  
  weighted_routing_policy {
    weight = 50
  }
  
  set_identifier = "primary"
  records        = ["192.0.2.1"]
}
```

### Latency-based Routing
- Routes based on lowest network latency
```hcl
resource "aws_route53_record" "latency" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "latency.example.com"
  type    = "A"
  
  latency_routing_policy {
    region = "us-west-2"
  }
  
  set_identifier = "us-west"
  records        = ["192.0.2.1"]
}
```

### Geolocation Routing
- Routes based on user location
```hcl
resource "aws_route53_record" "geo" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "geo.example.com"
  type    = "A"
  
  geolocation_routing_policy {
    country = "US"
  }
  
  set_identifier = "us"
  records        = ["192.0.2.1"]
}
```

### Failover Routing
- Routes traffic to backup site when primary fails
```hcl
resource "aws_route53_record" "failover" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "failover.example.com"
  type    = "A"
  
  failover_routing_policy {
    type = "PRIMARY"
  }
  
  set_identifier = "primary"
  records        = ["192.0.2.1"]
}
```

## Health Checks

Health checks monitor the health and performance of your resources.

```hcl
resource "aws_route53_health_check" "web" {
  fqdn              = "example.com"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
  
  tags = {
    Name = "web-health-check"
  }
}
```

## Traffic Flow

Traffic flow provides visual editor for complex routing configurations.

```hcl
resource "aws_route53_traffic_policy" "example" {
  name     = "example-policy"
  document = jsonencode({
    AWSPolicyFormatVersion = "2015-10-01"
    RecordType            = "A"
    Endpoints             = {
      "endpoint-1" = {
        Type  = "value"
        Value = "192.0.2.1"
      }
    }
    Rules                = {
      "rule-1" = {
        RuleType = "latency"
        Regions  = ["us-west-2"]
      }
    }
  })
}
```

## DNSSEC

Domain Name System Security Extensions (DNSSEC) provides authentication and integrity verification.

```hcl
resource "aws_route53_key_signing_key" "example" {
  hosted_zone_id             = aws_route53_zone.main.id
  key_management_service_arn = aws_kms_key.dnssec.arn
  name                      = "example"
}

resource "aws_route53_hosted_zone_dnssec" "example" {
  hosted_zone_id = aws_route53_zone.main.id
}
```

## Query Logging

Enables logging of DNS queries.

```hcl
resource "aws_route53_query_log" "example" {
  depends_on = [aws_cloudwatch_log_resource_policy.route53]

  cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53.arn
  zone_id                  = aws_route53_zone.main.zone_id
} 