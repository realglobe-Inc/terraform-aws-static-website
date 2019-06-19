variable "service_name" {}
variable "aws_profile" {}
variable "domain_names" {
  type = list(string)
}
variable "route53_zone_id" {}
variable "s3_bucket_name" {}
