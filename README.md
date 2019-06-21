
[![GitHub][github-image]][github-link]

  [github-image]: https://img.shields.io/github/release/realglobe-Inc/terraform-aws-static-website.svg
  [github-link]: https://github.com/realglobe-Inc/terraform-aws-static-website/releases

# terraform-aws-static-website

Provision a static website hosted through S3 + CloudFront in AWS

## Usage

```hcl
module "website" {
  source = "realglobe-Inc/static-website/aws"
  version = "1.0.0"
  service_name = "your-service-name"
  aws_profile = "aws-profile-name"
  domain_names = list("foo.example.com", "bar.example.com")
  route53_zone_id = "ZXXXXXXXXXXXXX"
  s3_bucket_name = "your-s3-web-bucket"
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
