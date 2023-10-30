// create kubernetes resources on eks cluster

resource "kubernetes_service" "fake-service" {
  metadata {
    name = var.name
    namespace = "fake-service"
    labels = {
        app = var.name
    }
  }
  spec {
    selector = {
      app = var.name
    }
    port {
      port        = 9090
      target_port = 9090
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service_account" "fake-service" {
  metadata {
    name = var.name
    namespace = "fake-service"
  }
  automount_service_account_token = true
}

resource "kubernetes_deployment" "fake-service" {
  metadata {
    name = var.name
    namespace = "fake-service"
  }
  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        service = var.name
        app = var.name
      }
    }
    template {
      metadata {
        labels = {
          service = var.name
          app = var.name
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" = true           
        }
      }
      spec {
        container {
          name  = "fake-service"
          image = "nicholasjackson/fake-service:v0.26.0"
          port {
            container_port = 9090
          }
          env {
            name = "UPSTREAM_URIS"
            value = var.upstream_uris
          }
          env {
            name = "NAME"
            value = var.name
          }
          env {
            name = "LISTEN_ADDR"
            value = "0.0.0.0:9090"
          }
        }
        service_account_name = var.name
      }
    }
  }
  wait_for_rollout = false
}