output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = google_api_gateway_gateway.gw.default_hostname
}

output "function_url" {
  description = "The direct URL of the Cloud Function"
  value       = google_cloudfunctions2_function.function.service_config[0].uri
}
