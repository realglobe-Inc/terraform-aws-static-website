variable "service_name" {
  description = "tagged with service name"
}
variable "aws_profile" {
  description = "aws profile name"
}
variable "domain_names" {
  description = "domain names"
  type = list(string)
}
variable "route53_zone_id" {
  description = "Route53 Zone ID"
}
variable "s3_bucket_name" {
  description = "S3 bucket name"
}
variable "save_access_log" {
  description = "whether save cloudfront access log to S3"
  type = bool
  default = false
}
