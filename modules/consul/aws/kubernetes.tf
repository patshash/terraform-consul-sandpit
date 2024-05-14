resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
}

resource "kubernetes_secret" "consul-bootstrap-token" {
  metadata {
    name      = "${var.deployment_name}-hcp-bootstrap-token"
    namespace = "consul"
  }

  data = {
    token = var.bootstrap_token
  }
}

resource "kubernetes_secret" "consul-client-secrets" {
  metadata {
    name      = "${var.deployment_name}-hcp-client-secrets"
    namespace = "consul"
  }

  data = {
    gossipEncryptionKey = var.gossip_encrypt_key
    caCert              = var.client_ca_cert
  }
}