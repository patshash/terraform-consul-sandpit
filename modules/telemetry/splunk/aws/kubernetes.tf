data "kubernetes_service" "splunk" {
  metadata {
    name = "splunk-stdln-standalone-service"
    namespace = var.namespace
  }
  
  depends_on = [
    helm_release.splunk-enterprise
  ]
}

data "kubernetes_secret" "splunk" {
  metadata {
    name = "splunk-${var.namespace}-secret"
    namespace = var.namespace
  }

  depends_on = [
  helm_release.splunk-enterprise
  ]
}