terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.43.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.17.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.0"
    }
    hcp = {
      source = "hashicorp/hcp"
      version = "~> 0.72.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.18.0"
    }
  }
}

provider "hcp" {
  client_id     = data.terraform_remote_state.tcm.outputs.hcp_client_id
  client_secret = data.terraform_remote_state.tcm.outputs.hcp_client_secret
}

provider "aws" {
  region = data.terraform_remote_state.tcm.outputs.aws_region
}

provider "google" {
  project = data.terraform_remote_state.tcm.outputs.gcp_project_id
  region  = data.terraform_remote_state.tcm.outputs.gcp_region
}

data "aws_eks_cluster" "default" {
  name = data.terraform_remote_state.tcm.outputs.deployment_id
}

data "aws_eks_cluster" "hashicups" {
  name = module.infra-aws.eks_cluster_id
}

provider "kubernetes" {
  alias = "eks"
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.name]
    command     = "aws"
  }
}

provider "kubernetes" {
  alias = "eks-hashicups"
  host                   = data.aws_eks_cluster.hashicups.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.hashicups.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.hashicups.name]
    command     = "aws"
  }
}

provider "helm" {
  alias = "eks-hashicups"
  kubernetes {
    host                   = data.aws_eks_cluster.hashicups.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.hashicups.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.hashicups.name]
      command     = "aws"
    }
  }
}

data "google_client_config" "default" {}

data "google_container_cluster" "default" {
  name     = "${data.terraform_remote_state.tcm.outputs.deployment_id}"
  location = data.terraform_remote_state.tcm.outputs.gcp_region
}

provider "kubernetes" {
  alias = "gke"
  host  = "https://${data.google_container_cluster.default.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.default.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  alias = "gke"
  kubernetes {
    host  = "https://${data.google_container_cluster.default.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.default.master_auth[0].cluster_ca_certificate,
    )
  }
}

provider "kubernetes" {
  alias = "gke-hashicups"
  host  = module.infra-gcp.cluster_api_endpoint
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.infra-gcp.cluster_ca_certificate)
}

provider "helm" {
  alias = "gke-hashicups"
  kubernetes {
  host  = module.infra-gcp.cluster_api_endpoint
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.infra-gcp.cluster_ca_certificate)
  }
}

provider "consul" {
  alias = "hcp"
  address        = data.terraform_remote_state.tcm.outputs.hcp_consul_public_fqdn
  scheme         = "https"
  datacenter     = "${data.terraform_remote_state.tcm.outputs.deployment_name}-hcp"
  token          = data.terraform_remote_state.tcm.outputs.hcp_consul_root_token
}

provider "consul" {
  alias = "gcp"
  address        = data.terraform_remote_state.tcm.outputs.gcp_consul_ui_public_fqdn
  scheme         = "https"
  datacenter     = "${data.terraform_remote_state.tcm.outputs.deployment_name}-gcp"
  token          = data.terraform_remote_state.tcm.outputs.gcp_consul_bootstrap_token
  insecure_https = true
}