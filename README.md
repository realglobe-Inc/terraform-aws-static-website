
[![GitHub][github-image]][github-link]

  [github-image]: https://img.shields.io/github/release/realglobe-Inc/terraform-aws-static-website.svg
  [github-link]: https://github.com/realglobe-Inc/terraform-aws-static-website/releases

# terraform-aws-static-website

Provision a static website hosted through S3 + CloudFront in AWS.

Terraform Registry at https://registry.terraform.io/modules/realglobe-Inc/static-website/aws/.

## Usage

```hcl
module "website" {
  source = "realglobe-Inc/static-website/aws"
  version = "2.3.2"

  providers = {
    aws.cloudfront = aws.<us-east-1 region alias>
  }

  service_name = "your-service-name"
  aws_profile = "aws-profile-name"
  domain_names = tolist(["foo.example.com", "bar.example.com"])
  route53_zone_id = "ZXXXXXXXXXXXXX"
  s3_bucket_name = "your-s3-web-bucket"
  cors_allowed_origins = tolist(["https://foo.example.com", "*.example.com"])  # optional
  cloudfront_origin_path = "/dev" # optional
  save_access_log = true  # optional
  lambda_function_associations = { "viewer-request": "arn:..." }  # optional
}
```

Output CloudFront cache invalidation command.

```hcl
output "cache_invalidation_command" {
  value = module.website.cache_invalidation_command
}
```

Create or switch workspace and apply.

```bash
$ terraform init
$ terraform workspace new development
$ terraform apply
```

Upload assets to S3.

```bash
$ aws s3 sync path/to/website/assets s3://your-s3-web-bucket/development/ --profile aws-profile-name
```

Then, access to your web site https://foo.example.com.

If responce is cached, invalidate CloudFront edge caches.

```bash
$ terraform output cache_invalidation_command
# Copy and paste printed command, overwrite paths and run.
```

## Development

To publish new version in Terraform Registry, just create new release in [releases](https://github.com/realglobe-Inc/terraform-aws-static-website/releases).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4 |
| <a name="provider_aws.cloudfront"></a> [aws.cloudfront](#provider\_aws.cloudfront) | >= 4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.web_dist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.hosting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_cors_configuration.hosting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_policy.hosting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_versioning.hosting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | aws profile name | `any` | n/a | yes |
| <a name="input_cloudfront_origin_path"></a> [cloudfront\_origin\_path](#input\_cloudfront\_origin\_path) | Origin path of CloudFront | `string` | `""` | no |
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | CORS allowed origins | `list(string)` | `[]` | no |
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | domain names | `list(string)` | n/a | yes |
| <a name="input_lambda_function_associations"></a> [lambda\_function\_associations](#input\_lambda\_function\_associations) | CloudFront Lambda function associations. key is CloudFront event type and value is lambda function ARN with version | `map(string)` | `{}` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route53 Zone ID | `any` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket name | `any` | n/a | yes |
| <a name="input_save_access_log"></a> [save\_access\_log](#input\_save\_access\_log) | whether save cloudfront access log to S3 | `bool` | `false` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | tagged with service name | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cache_invalidation_command"></a> [cache\_invalidation\_command](#output\_cache\_invalidation\_command) | CloudFront edge cache invalidation command. /path/to/invalidation/resource is like /index.html /error.html |
<!-- END_TF_DOCS -->
