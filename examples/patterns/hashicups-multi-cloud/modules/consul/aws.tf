// create kubernetes resources on hashicups eks cluster

resource "kubernetes_namespace" "eks-consul" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "consul"
  }
}

resource "kubernetes_secret" "eks-consul-bootstrap-token" {
  provider = kubernetes.eks-hashicups

  metadata {
    name      = "tphan-test-hcp-bootstrap-token"
    namespace = "consul"
  }

  data = {
    token = base64decode(yamldecode(hcp_consul_cluster_root_token.token.kubernetes_secret).data.token)
  }
}

resource "kubernetes_secret" "eks-consul-client-secrets" {
  provider = kubernetes.eks-hashicups

  metadata {
    name      = "tphan-test-hcp-client-secrets"
    namespace = "consul"
  }

  data = {
    gossipEncryptionKey = base64decode(yamldecode(data.hcp_consul_agent_kubernetes_secret.consul.secret).data.gossipEncryptionKey)
    caCert              = base64decode(yamldecode(data.hcp_consul_agent_kubernetes_secret.consul.secret).data.caCert)
  }

  depends_on = [
    kubernetes_namespace.eks-consul
  ]
}

// create and deploy consul hashicups partition helm

resource "local_file" "eks-client-hashicups-partition-helm-values" {
  content = templatefile("../../../examples/templates/hcp-consul-client-partition-helm.yml", {
    partition_name                = "hashicups"
    deployment_name               = "${var.deployment_name}-hcp"
    consul_version                = var.min_version
    external_server_private_fqdn  = trimprefix(data.hcp_consul_cluster.consul.consul_private_endpoint_url, "https://")
    external_server_https_port    = 443
    kubernetes_api_endpoint       = var.eks_kubernetes_api_endpoint
    replicas                      = var.replicas
    cloud                         = "aws"
    })
  filename = "${path.module}/eks-client-hashicups-partition-helm-values.yml.tmp"
}

resource "helm_release" "eks-consul-client-hashicups" {
  provider = helm.eks-hashicups

  name          = "${var.deployment_name}-consul-client"
  chart         = "consul"
  repository    = "https://helm.releases.hashicorp.com"
  version       = var.helm_chart_version
  namespace     = "consul"
  timeout       = "300"
  wait          = true
  values        = [
    local_file.eks-client-hashicups-partition-helm-values.content
  ]

  depends_on    = [
    kubernetes_namespace.eks-consul
  ]
}

// retreive consul hashicups partition ingress gateway public fqdn

data "kubernetes_service" "eks-consul-ingress-gateway" {
  provider = kubernetes.eks-hashicups

  metadata {
    name = "consul-aws-hashicups-ingress-gateway"
    namespace = "consul"
  }

  depends_on = [
    helm_release.eks-consul-client-hashicups
  ]
}

# // set consul default partition cluster peering through mesh gateways

# resource "consul_config_entry" "eks-mesh" {
#   provider = consul.hcp

#   name      = "mesh"
#   kind      = "mesh"

#   config_json = jsonencode({
#       Peering = {
#           PeerThroughMeshGateways = true
#       }
#   })
# }

// set consul default partition cluster peering through mesh gateways via kubernetes custom resource definition (crd), terraform resource consul_config_entry is not working, needs investigation.

resource "kubernetes_manifest" "eks-consul-mesh" {
  provider = kubernetes.eks

  manifest = yamldecode(file("../../../examples/manifests/mesh.yml"))
}