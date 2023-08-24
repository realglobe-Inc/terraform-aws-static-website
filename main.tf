locals {
  s3_origin_id = "${var.s3_bucket_name}${var.cloudfront_origin_path}"
}

################################################################################
# S3
################################################################################

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowCloudFront"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity.id}"]
    }
  }
}

resource "aws_s3_bucket" "hosting" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_policy" "hosting" {
  bucket = var.s3_bucket_name
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket_cors_configuration" "hosting" {
  bucket = aws_s3_bucket.hosting.id

  dynamic "cors_rule" {
    for_each = [for origin in var.cors_allowed_origins : {
      allowed_origin = origin
    }]

    content {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = [cors_rule.value.allowed_origin]
      max_age_seconds = 3000
    }
  }
}

resource "aws_s3_bucket_versioning" "hosting" {
  bucket = aws_s3_bucket.hosting.id

  versioning_configuration {
    status = "Enabled"
  }
}

################################################################################
# Cloudfront
################################################################################

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

################################################################################
# ACM Certificate
################################################################################

resource "aws_acm_certificate" "cert" {
  provider                  = aws.cloudfront
  domain_name               = var.domain_names[0]
  subject_alternative_names = slice(var.domain_names, 1, length(var.domain_names))
  validation_method         = "DNS"

  tags = {
    Name = "${var.service_name} web"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.cloudfront
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

################################################################################
# Route53 DNS records
################################################################################

resource "aws_route53_record" "www" {
  count   = length(var.domain_names)
  zone_id = var.route53_zone_id
  name    = var.domain_names[count.index]
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.web_dist.domain_name
    zone_id                = aws_cloudfront_distribution.web_dist.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cert_validation" {

  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = var.route53_zone_id
  records = [each.value.record]
  ttl     = 60
}
