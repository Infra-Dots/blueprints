output "cloudfront_domain_name" {
  description = "Domain name of CloudFront distribution"
  value       = module.cloudfront.cloudfront_distribution_domain_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}
