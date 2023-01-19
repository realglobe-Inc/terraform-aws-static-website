output "cache_invalidation_command" {
  description = "CloudFront edge cache invalidation command. /path/to/invalidation/resource is like /index.html /error.html"
  value       = "aws cloudfront create-invalidation --profile ${var.aws_profile} --distribution-id ${aws_cloudfront_distribution.web_dist.id} --paths /path/to/invalidation/resource"
}

output "s3_bucket_arn" {
  description = "S3 Bucket arn"
  value       = aws_s3_bucket.hosting.arn
}

output "s3_bucket_id" {
  description = "S3 Bucket name"
  value       = aws_s3_bucket.hosting.id
}
