output "public_fqdn" {
  description = "public fqdn"
  value       = data.kubernetes_service.prometheus.status.0.load_balancer.0.ingress.0.hostname
}