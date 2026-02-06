output "load_balancer_ip" {
  description = "The external IP address of the load balancer"
  value       = module.lb-http.external_ip
}

output "database_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = module.sql.instance_connection_name
}
