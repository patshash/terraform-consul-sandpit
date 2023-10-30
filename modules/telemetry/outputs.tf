// splunk outputs

output "splunk_public_fqdn" {
  description = "splunk service public fqdn"
  value       = "https://${module.splunk-enterprise-aws.public_fqdn}:8000"
}

output "splunk_admin_password" {
  description = "splunk admin password"
  value       = module.splunk-enterprise-aws.admin_password
  sensitive   = true
}

// grafana outputs

output "grafana_public_fqdn" {
  description = "grafana service public fqdn"
  value       = "http://${module.grafana-aws.public_fqdn}"
}