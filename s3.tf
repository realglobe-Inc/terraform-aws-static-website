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
  policy = data.aws_iam_policy_document.bucket_policy.json

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

  versioning {
    enabled = true
  }
}
