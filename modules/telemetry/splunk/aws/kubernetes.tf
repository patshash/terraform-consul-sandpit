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

data "kubernetes_all_namespaces" "allns" {}

resource "kubernetes_namespace" "telemetry" {
  for_each = toset([ for k in tolist([var.namespace]) : k if !contains(keys(data.kubernetes_all_namespaces.allns), k) ])
  metadata {
    name = each.key
  }

  depends_on = [
    data.kubernetes_all_namespaces.allns
  ]
}