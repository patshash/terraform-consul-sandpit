resource "kubernetes_service" "frontend" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "frontend"
    namespace = "frontend"
    labels = {
        app = "frontend"
    }
  }
  spec {
    selector = {
      app = "frontend"
    }
    port {
      port        = 3000
      target_port = 3000
    }
    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_service_account" "frontend" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "frontend"
    namespace = "frontend"
  }
  automount_service_account_token = true

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_deployment" "frontend" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "frontend"
    namespace = "frontend"
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        service = "frontend"
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          service = "frontend"
          app = "frontend"
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" = true           
        }
      }
      spec {
        container {
          name  = "frontend"
          image = "hashicorpdemoapp/frontend:v1.0.9"
          port {
            container_port = 3000
          }
          env {
            name = "NEXT_PUBLIC_PUBLIC_API_URL"
            value = "/"
          }
        }
        service_account_name = "frontend"
      }
    }
  }
  wait_for_rollout = false
  
  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "consul_config_entry" "si-frontend" {
  provider = consul.hcp

  name        = "frontend"
  kind        = "service-intentions"
  partition   = "hashicups"
  namespace   = "frontend"

  config_json = jsonencode({
    Sources = [
      {
        Partition  = "hashicups"
        Namespace  = "frontend"
        Action     = "allow"
        Name       = "nginx"
        Type       = "consul"
      }
    ]
  })

  depends_on = [
    time_sleep.wait_5_seconds
  ]
}