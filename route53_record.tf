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
  count   = length(var.domain_names)
  name    = lookup(tolist(aws_acm_certificate.cert.domain_validation_options)[count.index], "resource_record_name")
  type    = lookup(tolist(aws_acm_certificate.cert.domain_validation_options)[count.index], "resource_record_type")
  records = [lookup(tolist(aws_acm_certificate.cert.domain_validation_options)[count.index], "resource_record_value")]
  zone_id = var.route53_zone_id
  ttl     = 60

  lifecycle {
    ignore_changes = ["fqdn"]
  }
}
