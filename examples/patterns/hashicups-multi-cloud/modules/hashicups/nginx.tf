resource "kubernetes_service" "nginx" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "nginx"
    namespace = "frontend"
    labels = {
        app = "nginx"
    }
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_config_map" "nginx" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "nginx-config"
    namespace = "frontend"
  }

  data = {
    "nginx.conf" = "${file("${path.module}/config-maps/nginx-config.yml")}"
  }

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_service_account" "nginx" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "nginx"
    namespace = "frontend"
  }
  automount_service_account_token = true

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_deployment" "nginx" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "nginx"
    namespace = "frontend"
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        service = "nginx"
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          service = "nginx"
          app = "nginx"
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" = true           
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:stable-alpine"
          port {
            container_port = 80
          }
          volume_mount {
            name = "nginx-config"
            mount_path = "/etc/nginx"
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            failure_threshold     = 2
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 1
          }
        }
        service_account_name = "nginx"
        volume {
          name  = "nginx-config"
          config_map {
            name = "nginx-config"
            items {
              key = "nginx.conf"
              path = "nginx.conf"
            }
          }
        }
      }
    }
  }
  wait_for_rollout = false

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces,
  ]
}

resource "consul_config_entry" "ig-nginx" {
  provider = consul.hcp

  name        = "aws-hashicups-ingress-gateway"
  kind        = "ingress-gateway"
  partition   = "hashicups"
  namespace   = "default"

  config_json = jsonencode({
    Listeners = [
      {
        Port     = 80
        Protocol = "http"
        Services = [
          { 
            Name      = "nginx"
            Namespace = "frontend" 
            Hosts     = ["*"]
          }
        ]
      }
    ]
  })

  depends_on = [
    consul_config_entry.eks-proxy_defaults,
    time_sleep.wait_5_seconds
  ]
}

resource "consul_config_entry" "si-nginx" {
  provider = consul.hcp

  name        = "nginx"
  kind        = "service-intentions"
  partition   = "hashicups"
  namespace   = "frontend"

  config_json = jsonencode({
    Sources = [
      {
        Partition  = "hashicups"
        Namespace  = "default"
        Action     = "allow"
        Name       = "aws-hashicups-ingress-gateway"
        Type       = "consul"
      }
    ]
  })

  depends_on = [
    time_sleep.wait_5_seconds
  ]
}