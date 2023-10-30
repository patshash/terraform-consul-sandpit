data "kubernetes_service" "prometheus" {
  metadata {
    name = "${var.deployment_name}-prometheus-server"
    namespace = var.namespace
  }
  
  depends_on = [
    helm_release.prometheus
  ]
}