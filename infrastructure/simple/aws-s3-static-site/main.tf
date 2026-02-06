provider "aws" {
  region = var.region
}

locals {
  bucket_name = "${var.project_name}-static-site"
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.10"

  bucket = local.bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  force_destroy = true
}

module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"
  version = "~> 6.3"

  comment             = "CloudFront for ${local.bucket_name}"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket = "My cloudfront entry"
  }

  origin = {
    s3_bucket = {
      domain_name = module.s3_bucket.s3_bucket_bucket_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_bucket"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  viewer_certificate = {
    cloudfront_default_certificate = true
  }
}

# Policy to allow CloudFront OAI to read from the bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [module.cloudfront.cloudfront_origin_access_identity_iam_arns["s3_bucket"]]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}
