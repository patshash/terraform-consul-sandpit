data "terraform_remote_state" "tcm" {
  backend = "local"

  config = {
    path = "../../../terraform.tfstate"
  }
}

data "google_compute_network" "vpc" {
  name   = data.terraform_remote_state.tcm.outputs.deployment_id
}

data "google_compute_subnetwork" "private" {
  name   = "private"
}

// amazon web services (aws) infrastructure

module "infra-aws" {
  source  = "./modules/infra/aws"
  
  deployment_id               = data.terraform_remote_state.tcm.outputs.deployment_id
  region                      = data.terraform_remote_state.tcm.outputs.aws_region
  key_pair_key_name           = data.terraform_remote_state.tcm.outputs.aws_key_pair_name
  vpc_id                      = data.terraform_remote_state.tcm.outputs.aws_vpc_id
  eks_cluster_version         = var.aws_eks_cluster_version
  eks_cluster_service_cidr    = var.aws_eks_cluster_service_cidr
  eks_worker_instance_type    = var.aws_eks_worker_instance_type
  eks_worker_desired_capacity = var.aws_eks_worker_desired_capacity
}

// google cloud platform (gcp) infrastructure

module "infra-gcp" {
  source = "./modules/infra/gcp"

  region              = data.terraform_remote_state.tcm.outputs.gcp_region
  project_id          = data.terraform_remote_state.tcm.outputs.gcp_project_id
  deployment_id       = data.terraform_remote_state.tcm.outputs.deployment_id
  vpc_name            = data.google_compute_network.vpc.name
  private_subnet_name = data.google_compute_subnetwork.private.name
}

// hcp consul

module "consul" {
  source = "./modules/consul"
  providers = {
    kubernetes.eks           = kubernetes.eks
    kubernetes.eks-hashicups = kubernetes.eks-hashicups
    kubernetes.gke           = kubernetes.gke
    kubernetes.gke-hashicups = kubernetes.gke-hashicups
    helm.eks-hashicups       = helm.eks-hashicups
    helm.gke-hashicups       = helm.gke-hashicups
    consul.hcp               = consul.hcp
    consul.gcp               = consul.gcp
   } 

  deployment_name             = data.terraform_remote_state.tcm.outputs.deployment_name
  min_version                 = data.terraform_remote_state.tcm.outputs.consul_version
  helm_chart_version          = data.terraform_remote_state.tcm.outputs.consul_helm_chart_version
  replicas                    = var.consul_replicas
  eks_kubernetes_api_endpoint = data.aws_eks_cluster.hashicups.endpoint
  gke_kubernetes_api_endpoint = module.infra-gcp.cluster_api_endpoint
}

// hashicups

module "hashicups" {
  source = "./modules/hashicups"
  providers = {
    kubernetes.eks-hashicups = kubernetes.eks-hashicups
    kubernetes.gke-hashicups = kubernetes.gke-hashicups
    consul.hcp               = consul.hcp
    consul.gcp               = consul.gcp
  }

  depends_on = [
    module.consul
  ]
}