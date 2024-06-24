// retrieve consul server data

data "kubernetes_service" "consul-partition-service-fqdn" {
  provider = kubernetes.gke

  metadata {
    name = "consul-expose-servers"
    namespace = "consul"
  }
}

data "kubernetes_secret" "consul-ca-cert" {
  provider = kubernetes.gke

  metadata {
    name = "consul-ca-cert"
    namespace = "consul"
  }
}

data "kubernetes_secret" "consul-ca-key" {
  provider = kubernetes.gke

  metadata {
    name = "consul-ca-key"
    namespace = "consul"
  }
}

data "kubernetes_secret" "consul-bootstrap-token" {
  provider = kubernetes.gke

  metadata {
    name = "consul-bootstrap-acl-token"
    namespace = "consul"
  }
}

// create admin partition on consul server

resource "consul_admin_partition" "gke-hashicups" {
  provider = consul.gcp

  name        = "hashicups"
  description = "Partition for hashicups team"
}

// create kubernetes resources on hashicups gke cluster

resource "kubernetes_namespace" "gke-consul" {
  provider = kubernetes.gke-hashicups

  metadata {
    name = "consul"
  }
}

resource "kubernetes_secret" "gke-consul-bootstrap-token" {
  provider = kubernetes.gke-hashicups

  metadata {
    name      = "${var.deployment_name}-gcp-bootstrap-token"
    namespace = "consul"
  }

  data = {
    token = data.kubernetes_secret.consul-bootstrap-token.data.token
  }

  depends_on = [
    kubernetes_namespace.gke-consul
  ]
}

resource "kubernetes_secret" "gke-consul-client-secrets" {
  provider = kubernetes.gke-hashicups

  metadata {
    name      = "${var.deployment_name}-gcp-client-secrets"
    namespace = "consul"
  }

  data = {
    gossipEncryptionKey = ""
    caCert              = data.kubernetes_secret.consul-ca-cert.data["tls.crt"]
    caKey               = data.kubernetes_secret.consul-ca-key.data["tls.key"]
  }

  depends_on = [
    kubernetes_namespace.gke-consul
  ]
}

// create and deploy consul hashicups partition helm

resource "local_file" "gke-client-hashicups-partition-helm-values" {
  content = templatefile("../../../examples/templates/gke-consul-client-partition-helm.yml", {
    partition_name                = "hashicups"
    deployment_name               = "${var.deployment_name}-gcp"
    consul_version                = var.min_version
    external_server_private_fqdn  = data.kubernetes_service.consul-partition-service-fqdn.status.0.load_balancer.0.ingress.0.ip
    external_server_https_port    = 8501
    kubernetes_api_endpoint       = var.gke_kubernetes_api_endpoint
    replicas                      = var.replicas
    cloud                         = "gcp"
    })
  filename = "${path.module}/gke-client-hashicups-partition-helm-values.yml.tmp"
}

resource "helm_release" "gke-consul-client-hashicups" {
  provider = helm.gke-hashicups

  name          = "${var.deployment_name}-consul-client"
  chart         = "consul"
  repository    = "https://helm.releases.hashicorp.com"
  version       = var.helm_chart_version
  namespace     = "consul"
  timeout       = "300"
  wait          = true
  values        = [
    local_file.gke-client-hashicups-partition-helm-values.content
  ]

  depends_on    = [
    kubernetes_namespace.gke-consul
  ]
}

# // set consul default partition cluster peering through mesh gateways

# resource "consul_config_entry" "gke-mesh" {
#   provider = consul.gcp

#   name      = "mesh"
#   kind      = "mesh"

#   config_json = jsonencode({
#     Peering = {
#       PeerThroughMeshGateways = true
#     }
#   })
# }

// set consul default partition cluster peering through mesh gateways via kubernetes custom resource definition (crd), terraform resource consul_config_entry is not working, needs investigation.

resource "kubernetes_manifest" "gke-consul-mesh" {
  provider = kubernetes.gke

  manifest = yamldecode(file("../../../examples/manifests/mesh.yml"))
}

// create default partition cluster peering connection between aws and gcp

resource "consul_peering" "aws-gcp-default" {
  provider = consul.gcp

  peer_name     = "aws-gcp-default"
  peering_token = consul_peering_token.aws-gcp-default.peering_token
}

// create hashicups partition cluster peering connection between aws and gcp

resource "consul_peering" "aws-gcp-hashicups" {
  provider = consul.gcp

  peer_name     = "aws-gcp-hashicups"
  peering_token = consul_peering_token.aws-gcp-hashicups.peering_token
  partition     = consul_admin_partition.gke-hashicups.name
}