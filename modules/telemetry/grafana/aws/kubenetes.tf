data "kubernetes_service" "grafana" {
  metadata {
    name      = "${var.deployment_name}-grafana"
    namespace = var.namespace
  }
  depends_on  = [
    helm_release.grafana
  ]
}