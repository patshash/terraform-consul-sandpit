resource "kubernetes_service" "product-api-db" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "product-api-db"
    namespace = "products"
    labels = {
        app = "product-api-db"
    }
  }
  spec {
    selector = {
      app = "product-api-db"
    }
    port {
      port        = 5432
      target_port = 5432
    }
    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_service_account" "product-api-db" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "product-api-db"
    namespace = "products"
  }
  automount_service_account_token = true

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_deployment" "product-api-db" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "product-api-db"
    namespace = "products"
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        service = "product-api-db"
        app = "product-api-db"
      }
    }
    template {
      metadata {
        labels = {
          service = "product-api-db"
          app = "product-api-db"
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" = true           
        }
      }
      spec {
        container {
          name  = "product-api-db"
          image = "hashicorpdemoapp/product-api-db:v0.0.22"
          port {
            container_port = 5432
          }
          env {
            name = "POSTGRES_DB"
            value = "products"
          }
          env {
            name = "POSTGRES_USER"
            value = "postgres"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = "password"
          }
          volume_mount {
            name = "pgdata"
            mount_path = "/var/lib/postgresql/data"
          }
        }
        service_account_name = "product-api-db"
        volume {
          name  = "pgdata"
          empty_dir {
          }
        }
      }
    }
  }
  wait_for_rollout = false

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "consul_config_entry" "sd-product-api-db" {
  provider = consul.hcp

  kind        = "service-defaults"
  name        = "product-api-db"
  partition   = "hashicups"
  namespace   = "products"

  config_json = jsonencode({
    Protocol    = "tcp"
  })

  depends_on = [
    time_sleep.wait_5_seconds
  ]
}

resource "consul_config_entry" "si-product-api-db" {
  provider = consul.hcp

  name        = "product-api-db"
  kind        = "service-intentions"
  partition   = "hashicups"
  namespace   = "products"

  config_json = jsonencode({
    Sources = [
      {
        Partition  = "hashicups"
        Namespace  = "products"
        Action     = "allow"
        Name       = "product-api"
        Type       = "consul"
      }
    ]
  })

  depends_on = [
    time_sleep.wait_5_seconds
  ]
}