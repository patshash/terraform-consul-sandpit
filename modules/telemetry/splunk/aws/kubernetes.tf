data "kubernetes_service" "splunk" {
  metadata {
    name = "splunk-stdln-standalone-service"
    namespace = "telemetry"
  }
  
  depends_on = [
    helm_release.splunk-enterprise
  ]
}

data "kubernetes_secret" "splunk" {
  metadata {
    name = "splunk-splunk-secret"
    namespace = "telemetry"
  }

  depends_on = [
  helm_release.splunk-enterprise
  ]
}

resource "kubernetes_namespace" "telemetry" {
  metadata {
    name = "telemetry"
  }
}