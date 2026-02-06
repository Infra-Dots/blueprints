output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}
