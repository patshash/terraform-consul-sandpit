// create kv on consul cluster

resource "consul_keys" "fake-service" {
  provider = consul.hcp

  key {
    path   = "app/fake-service/logging/loglevel"
    value  = "info"
    delete = true
  }
}

// create secret on vault cluster

resource "vault_kv_secret_v2" "fake-service" {
  provider = vault.hcp

  mount                      = "app"
  name                       = "fake-service/database"
  delete_all_versions        = true
  data_json                  = jsonencode(
  {
    username  = "admin",
    password  = "Passw0rd1!"
  }
  )
}


// create kubernetes resources on eks cluster

resource "kubernetes_namespace" "fake-service" {
  provider = kubernetes.eks

  metadata {
    name = "fake-service"
  }
}

resource "kubernetes_service" "fake-service" {
  provider = kubernetes.eks

  metadata {
    name = "fake-service"
    namespace = "fake-service"
    labels = {
        app = "fake-service"
    }
  }
  spec {
    selector = {
      app = "fake-service"
    }
    port {
      port        = 9090
      target_port = 9090
    }
    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.fake-service
  ]
}

resource "kubernetes_config_map" "fake-service" {
  provider = kubernetes.eks

  metadata {
    name = "app-settings"
    namespace = "fake-service"
  }

  data = {
    "app-settings.json" = "${file("${path.module}/config-maps/app-settings.json.tmp")}"
  }

  depends_on = [
    kubernetes_namespace.fake-service
  ]
}

resource "kubernetes_service_account" "fake-service" {
  provider = kubernetes.eks

  metadata {
    name = "fake-service"
    namespace = "fake-service"
  }
  automount_service_account_token = true

  depends_on = [
    kubernetes_namespace.fake-service
  ]
}

resource "kubernetes_deployment" "fake-service" {
  provider = kubernetes.eks

  metadata {
    name = "fake-service"
    namespace = "fake-service"
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        service = "fake-service"
        app = "fake-service"
      }
    }
    template {
      metadata {
        labels = {
          service = "fake-service"
          app = "fake-service"
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" = true           
        }
      }
      spec {
        init_container {
          name  = "consul-template-init"
          image = "phantony/consul-template:0.33.0"
          volume_mount {
            name = "app-settings"
            mount_path = "/etc/app-settings"
          }
          volume_mount {
            name = "app-settings-result"
            mount_path = "/app/config"
          }
          env {
            name = "TEMPLATE_PATH"
            value = "/etc/app-settings/app-settings.json"
          }
          env {
            name = "RESULT_PATH"
            value = "/app/config/app-settings.json"
          }
          env {
            name = "EXTRA_ARGS"
            value = "-once"
          }
          env {
            name = "CONSUL_HTTP_ADDR"
            value = var.consul_addr
          }
          env {
            name = "CONSUL_HTTP_TOKEN"
            value = var.consul_token
          }
          env {
            name = "CONSUL_HTTP_SSL"
            value = true
          }
          env {
            name = "CONSUL_HTTP_SSL_VERIFY"
            value = false
          }
          env {
            name = "VAULT_ADDR"
            value = var.vault_addr
          }
          env {
            name = "VAULT_NAMESPACE" // required for hcp vault
            value = "admin"
          }
          env {
            name = "VAULT_TOKEN"
            value = var.vault_token
          }
        }
        container {
          name  = "fake-service"
          image = "nicholasjackson/fake-service:v0.25.2"
          port {
            container_port = 9090
          }
          volume_mount {
            name = "app-settings-result"
            mount_path = "/app/config"
          }
          env {
            name = "LISTEN_ADDR"
            value = "0.0.0.0:9090"
          }
          env {
            name = "NAME"
            value = "service-a"
          }
        }
        service_account_name = "fake-service"
        volume {
          name  = "app-settings"
          config_map {
            name = "app-settings"
            items {
              key = "app-settings.json"
              path = "app-settings.json"
            }
          }
        }
        volume {
          name  = "app-settings-result"
          empty_dir {
            medium = "Memory"
          }
        }
      }
    }
  }
  wait_for_rollout = false

  depends_on = [
    kubernetes_namespace.fake-service
  ]
}