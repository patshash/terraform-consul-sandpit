data "kubernetes_service" "splunk" {
  metadata {
    name = "splunk-stdln-standalone-service"
    namespace = "splunk"
  }
  
  depends_on = [
    helm_release.splunk-enterprise
  ]
}

data "kubernetes_secret" "splunk" {
  metadata {
    name = "splunk-splunk-secret"
    namespace = "splunk"
  }

  depends_on = [
  helm_release.splunk-enterprise
  ]
}

resource "kubernetes_namespace" "splunk" {
  metadata {
    name = "splunk"
  }
}