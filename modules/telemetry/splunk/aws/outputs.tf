output "public_fqdn" {
  description = "public fqdn"
  value       = data.kubernetes_service.splunk.status.0.load_balancer.0.ingress.0.hostname
}

output "admin_password" {
  description = "admin password"
  value       = data.kubernetes_secret.splunk.data.password
}

output "hec_token" {
  description = "hec password"
  value       = data.kubernetes_secret.splunk.data.hec_token
}