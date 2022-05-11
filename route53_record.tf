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
