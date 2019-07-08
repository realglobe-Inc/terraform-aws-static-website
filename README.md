
[![GitHub][github-image]][github-link]

  [github-image]: https://img.shields.io/github/release/realglobe-Inc/terraform-aws-static-website.svg
  [github-link]: https://github.com/realglobe-Inc/terraform-aws-static-website/releases

# terraform-aws-static-website

Provision a static website hosted through S3 + CloudFront in AWS

## Usage

```hcl
module "website" {
  source = "realglobe-Inc/static-website/aws"
  version = "2.0.0"
  service_name = "your-service-name"
  aws_profile = "aws-profile-name"
  domain_names = list("foo.example.com", "bar.example.com")
  route53_zone_id = "ZXXXXXXXXXXXXX"
  s3_bucket_name = "your-s3-web-bucket"
  cloudfront_origin_path = "/dev" # optional
  save_access_log = true  # optional
}
```

Output CroudFront cache invalidation command.

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
