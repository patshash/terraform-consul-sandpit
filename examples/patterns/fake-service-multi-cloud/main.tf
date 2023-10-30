data "terraform_remote_state" "tcm" {
  backend = "local"

  config = {
    path = "../../../terraform.tfstate"
  }
}

resource "kubernetes_namespace" "fake-service-eks" {
  provider = kubernetes.eks

  metadata {
    name = "fake-service"
  }
}

resource "kubernetes_namespace" "fake-service-gke" {
  provider = kubernetes.gke

  metadata {
    name = "fake-service"
  }
}

module "fake-service-a" {
  source  = "./modules/fake-service"
  providers = {
    kubernetes = kubernetes.eks
  }

  upstream_uris = "http://service-b.virtual.fake-service.ns.consul"
  name          = "service-a"
  replicas      = 2

  depends_on = [ 
    kubernetes_namespace.fake-service-eks
  ]
}

module "fake-service-b" {
  source  = "./modules/fake-service"
  providers = {
    kubernetes = kubernetes.eks
  }

  upstream_uris = ""
  name          = "service-b"
  replicas      = 2

  depends_on = [ 
    kubernetes_namespace.fake-service-eks
  ]
}

module "fake-service-c" {
  source  = "./modules/fake-service"
  providers = {
    kubernetes = kubernetes.gke
  }

  upstream_uris = ""
  name     = "service-c"
  replicas = 9

  depends_on = [ 
    kubernetes_namespace.fake-service-gke 
  ]
}

// consul configuration

resource "consul_config_entry" "pd-hcp" {
  provider = consul.hcp

  kind        = "proxy-defaults"
  name        = "global"
  partition   = "default"

  config_json = jsonencode({
    Config = {
      Protocol = "http"
    }
    "AccessLogs": {
    "Enabled": true
  }
  })
}

resource "consul_config_entry" "pd-gcp" {
  provider = consul.gcp
  
  kind        = "proxy-defaults"
  name        = "global"
  partition   = "default"

  config_json = jsonencode({
    Config = {
      Protocol = "http"
    }
    "AccessLogs": {
      "Enabled": true
      # "JSONFormat": "{ \"myCustomKey\" : { \"myStartTime\" : \"%START_TIME%\", \"myProtocol\" : \"%PROTOCOL%\"} }"
    }
  })
}

resource "consul_config_entry" "si-service-b" {
  provider = consul.hcp

  name        = "service-b"
  kind        = "service-intentions"
  partition   = "default"
  namespace   = "fake-service"

  config_json = jsonencode({
    Sources = [
      {
        Partition  = "default"
        Namespace  = "fake-service"
        Action     = "allow"
        Name       = "service-a"
        Type       = "consul"
      }
    ]
  })
}

resource "consul_config_entry" "ig-service-a" {
  provider = consul.hcp

  name        = "aws-default-ingress-gateway"
  kind        = "ingress-gateway"
  partition   = "default"
  namespace   = "default"

  config_json = jsonencode({
    Listeners = [
      {
        Port     = 80
        Protocol = "http"
        Services = [
          { 
            Name      = "service-a"
            Namespace = "fake-service" 
            Hosts     = ["*"]
          }
        ]
      }
    ]
  })

  depends_on = [ 
    consul_config_entry.pd-hcp
  ]
}

resource "consul_config_entry" "si-service-a" {
  provider = consul.hcp

  name        = "service-a"
  kind        = "service-intentions"
  partition   = "default"
  namespace   = "fake-service"

  config_json = jsonencode({
    Sources = [
      {
        Partition  = "default"
        Namespace  = "default"
        Action     = "allow"
        Name       = "aws-default-ingress-gateway"
        Type       = "consul"
      }
    ]
  })
}