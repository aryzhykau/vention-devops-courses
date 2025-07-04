resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = var.s3_domain
    origin_id   = "s3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

restrictions {
  geo_restriction {
    restriction_type = "none"
  }
}

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

