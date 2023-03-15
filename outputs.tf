// generic outputs

output "deployment_id" {
  description = "Deployment identifier"
  value       = local.deployment_id
}

output "deployment_name" {
  description = "Deployment name, used to prefix resources"
  value       = var.deployment_name
}

output "consul_version" {
  description = "Consul version"
  value       = var.consul_version
}

// amazon web services (aws) outputs

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "aws_vpc_id" {
  description = "AWS VPC id"
  value       = module.infra-aws.vpc_id
}

output "aws_key_pair_name" {
  description = "AWS key pair name"
  value       = module.infra-aws.key_pair_name
}

output "aws_bastion_public_fqdn" {
  description = "AWS public fqdn of bastion node"
  value       = module.infra-aws.bastion_public_fqdn
}

output "aws_consul_default_ingress_public_fqdn" {
  description = "Consul ingress gateway fqdn"
  value       = "http://${module.consul-client-aws.ingress_public_fqdn}"
}

# output "aws_grafana_public_fqdn" {
#   description = "Grafana public fqdn"
#   value       = "http://${module.grafana.public_fqdn}"
# }

// google gloud platform (gcp) outputs

output "gcp_region" {
  description = "GCP region"
  value       = var.gcp_region
}

output "gcp_project_id" {
  description = "GCP project"
  value       = var.gcp_project_id
}

output "gcp_consul_ui_public_fqdn" {
  description = "GCP consul datacenter ui public fqdn"
  value       = "https://${module.consul-server-gcp.ui_public_fqdn}"
}

output "gcp_consul_bootstrap_token" {
  description = "GCP consul acl bootstrap token"
  value       = module.consul-server-gcp.bootstrap_token
  sensitive   = true
}

// hashicorp cloud platform (hcp) outputs

output "hcp_region" {
  description = "HCP region"
  value       = var.hcp_region
}

output "hcp_client_id" {
  description = "HCP client id"
  value       = var.hcp_client_id
  sensitive   = true
}

output "hcp_client_secret" {
  description = "HCP client secret"
  value       = var.hcp_client_secret
  sensitive   = true
}

output "hcp_consul_public_fqdn" {
  description = "HCP consul public fqdn"
  value       = module.hcp-consul.public_endpoint_url
}

output "hcp_consul_root_token" {
  description = "HCP consul root token"
  value       = module.hcp-consul.root_token
  sensitive   = true
}

// hashicorp self-managed consul outputs

output "consul_helm_chart_version" {
  description = "Helm chart version"
  value       = var.consul_helm_chart_version
}