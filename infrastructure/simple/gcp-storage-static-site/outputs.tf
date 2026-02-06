output "load_balancer_ip" {
  description = "External IP of the Load Balancer"
  value       = module.lb-http.external_ip
}

output "bucket_name" {
  description = "Name of the created GCS bucket"
  value       = module.gcs_bucket.name
}
