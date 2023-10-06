// create kubernetes resources on hashicups eks cluster

resource "kubernetes_namespace" "eks-hashicups-namespaces" {
  provider = kubernetes.eks-hashicups

  for_each = toset(var.hashicups_config.aws.eks_namespaces)

  metadata {
    name = each.key
  }
}

resource "kubernetes_namespace" "gke-hashicups-namespaces" {
  provider = kubernetes.gke-hashicups

  for_each = toset(var.hashicups_config.gcp.gke_namespaces)

  metadata {
    name = each.key
  }
}

resource "consul_config_entry" "eks-proxy_defaults" {
  provider = consul.hcp

  kind        = "proxy-defaults"
  name        = "global"
  partition   = "hashicups"

  config_json = jsonencode({
    Config = {
      Protocol = "http"
    }
  })
}

resource "consul_config_entry" "gke-proxy_defaults" {
  provider = consul.gcp

  kind        = "proxy-defaults"
  name        = "global"
  partition   = "hashicups"

  config_json = jsonencode({
    Config = {
      Protocol = "http"
    }
  })
}

resource "time_sleep" "wait_5_seconds" {
  create_duration = "5s"

  depends_on = [
    kubernetes_deployment.nginx,
    kubernetes_deployment.frontend,
    kubernetes_deployment.public-api,
    kubernetes_deployment.product-api,
    kubernetes_deployment.product-api-db,
    kubernetes_deployment.payments-api
  ]
}