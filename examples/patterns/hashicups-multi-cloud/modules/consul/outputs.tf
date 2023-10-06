// amazon web services (aws) outputs

output "ingress_public_fqdn" {
  description = "Ingress gateway public fqdn"
  value       = data.kubernetes_service.eks-consul-ingress-gateway.status.0.load_balancer.0.ingress.0.hostname
}