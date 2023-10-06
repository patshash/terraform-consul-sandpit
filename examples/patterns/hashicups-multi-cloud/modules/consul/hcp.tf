// retrieve hcp consul data

data "hcp_consul_cluster" "consul" {
  cluster_id = "${var.deployment_name}-hcp"
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = data.hcp_consul_cluster.consul.id
}

data "hcp_consul_agent_kubernetes_secret" "consul" {
  cluster_id = data.hcp_consul_cluster.consul.cluster_id
}

// create admin partition on hcp consul

resource "consul_admin_partition" "hcp-hashicups" {
  provider = consul.hcp

  name        = "hashicups"
  description = "Partition for hashicups team"
}

// create default partition cluster peering token for aws and gcp

resource "consul_peering_token" "aws-gcp-default" {
  provider = consul.hcp

  peer_name = "aws-gcp-default"

  depends_on = [
    kubernetes_manifest.eks-consul-mesh,
    kubernetes_manifest.gke-consul-mesh
  ]
}

// create hashicups partition cluster peering token for aws and gcp

resource "consul_peering_token" "aws-gcp-hashicups" {
  provider = consul.hcp

  peer_name = "aws-gcp-hashicups"
  partition = consul_admin_partition.hcp-hashicups.name

  depends_on = [
    kubernetes_manifest.eks-consul-mesh,
    kubernetes_manifest.gke-consul-mesh
  ]
}