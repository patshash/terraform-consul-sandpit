data "kubernetes_service" "consul-ui" {
  metadata {
    name = "consul-ui"
    namespace = "consul"
  }
  
  depends_on = [
    helm_release.consul-server
  ]
}

data "kubernetes_secret" "consul-bootstrap-token" {
  metadata {
    name = "consul-bootstrap-acl-token"
    namespace = "consul"
  }

  depends_on = [
  helm_release.consul-server
  ]
}

resource "kubernetes_namespace" "consul" {
  metadata {
    name      = "consul"
  }
}

resource "kubernetes_secret" "consul-ent-license" {
  metadata {
    name = "consul-ent-license"
    namespace = "consul"
  }

  data = {
    key = var.consul_ent_license
  }
}