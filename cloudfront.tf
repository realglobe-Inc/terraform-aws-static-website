locals {
  s3_origin_id = "${var.s3_bucket_name}${var.cloudfront_origin_path}"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "website"
}

resource "aws_cloudfront_distribution" "web_dist" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.service_name
  default_root_object = "index.html"
  price_class         = "PriceClass_200"
  aliases             = var.domain_names

  origin {
    domain_name = aws_s3_bucket.hosting.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    origin_path = var.cloudfront_origin_path

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  # SPA用のエラーハンドリング
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  # ifが使えないのでdynamicを使う
  dynamic "logging_config" {
    for_each = var.save_access_log ? { "dummy" : "dummy" } : {}

    content {
      include_cookies = true
      bucket          = aws_s3_bucket.hosting.bucket_domain_name
      prefix          = "cf-logs-${terraform.workspace}"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id
    compress         = true

    forwarded_values {
      query_string = false
      headers      = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    dynamic "lambda_function_association" {
      for_each = var.lambda_function_associations
      content {
        event_type = lambda_function_association.key
        lambda_arn = lambda_function_association.value
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}
