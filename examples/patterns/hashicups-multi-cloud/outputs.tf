// amazon web services (aws) outputs

output "aws_consul_hashicups_ingress_public_fqdn" {
  description = "Consul ingress gateway fqdn"
  value       = "http://${module.consul.ingress_public_fqdn}"
}