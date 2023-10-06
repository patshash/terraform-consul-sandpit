output "cluster_api_endpoint" {
  description = "GKE cluster endpoint"
  value       = "https://${module.gke.endpoint}"
}

output "cluster_ca_certificate" {
  description = "GKE ca certificate"
  value       = module.gke.ca_certificate
}
