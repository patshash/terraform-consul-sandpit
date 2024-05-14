// generic outputs

output "deployment_id" {
  description = "deployment identifier"
  value       = local.deployment_id
}

output "deployment_name" {
  description = "deployment name to prefix resources"
  value       = var.deployment_name
}

output "consul_version" {
  description = "consul version"
  value       = var.consul_version
}

// amazon web services (aws) outputs

output "aws_region" {
  description = "aws region"
  value       = var.aws_region
}

output "aws_vpc_id" {
  description = "aws vpc id"
  value       = module.infra-aws.vpc_id
}

output "aws_key_pair_name" {
  description = "aws key pair name"
  value       = module.infra-aws.key_pair_name
}

output "aws_bastion_public_fqdn" {
  description = "aws public fqdn of bastion node"
  value       = module.infra-aws.bastion_public_fqdn
}

// google gloud platform (gcp) outputs

output "gcp_region" {
  description = "gcp region"
  value       = var.gcp_region
}

output "gcp_project_id" {
  description = "gcp project"
  value       = var.gcp_project_id
}

output "gcp_consul_ui_public_fqdn" {
  description = "gcp consul datacenter ui public fqdn"
  value       = "https://${module.consul-server-gcp.ui_public_fqdn}"
}

output "gcp_consul_bootstrap_token" {
  description = "gcp consul acl bootstrap token"
  value       = module.consul-server-gcp.bootstrap_token
  sensitive   = true
}

// hashicorp cloud platform (hcp) outputs

output "hcp_client_id" {
  description = "hcp client id"
  value       = var.hcp_client_id
  sensitive   = true
}

output "hcp_client_secret" {
  description = "hcp client secret"
  value       = var.hcp_client_secret
  sensitive   = true
}

output "hcp_consul_public_fqdn" {
  description = "hcp consul public fqdn"
  value       = module.consul-hcp.public_endpoint_url
}

output "hcp_consul_root_token" {
  description = "hcp consul root token"
  value       = module.consul-hcp.root_token
  sensitive   = true
}

output "hcp_vault_public_fqdn" {
  description = "HCP vault public fqdn"
  value       = var.enable_hcp_vault == true ? module.vault-hcp[0].public_endpoint_url : null
}

output "hcp_vault_root_token" {
  description = "HCP vault root token"
  value       = var.enable_hcp_vault == true ? module.vault-hcp[0].root_token : null
  sensitive   = true
}

// hashicorp self-managed consul outputs

output "consul_helm_chart_version" {
  description = "Helm chart version"
  value       = var.consul_helm_chart_version
}

// telemetry outputs

output "splunk_public_fqdn" {
  description = "splunk service public fqdn"
  value       = var.enable_telemetry == true ? module.telemetry[0].splunk_public_fqdn : null
}

output "splunk_admin_password" {
  description = "splunk admin password"
  value       = var.enable_telemetry == true ? module.telemetry[0].splunk_admin_password : null
  sensitive   = true
}

output "grafana_public_fqdn" {
  description = "splunk service public fqdn"
  value       = var.enable_telemetry == true ? module.telemetry[0].grafana_public_fqdn : null
}