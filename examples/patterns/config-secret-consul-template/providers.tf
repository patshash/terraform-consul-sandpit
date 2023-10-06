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
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.16.2"
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

data "aws_eks_cluster" "default" {
  name = data.terraform_remote_state.tcm.outputs.deployment_id
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

provider "consul" {
  alias = "hcp"
  address        = data.terraform_remote_state.tcm.outputs.hcp_consul_public_fqdn
  scheme         = "https"
  datacenter     = "${data.terraform_remote_state.tcm.outputs.deployment_name}-hcp"
  token          = data.terraform_remote_state.tcm.outputs.hcp_consul_root_token
}

provider "vault" {
  alias = "hcp"
  address        = data.terraform_remote_state.tcm.outputs.hcp_vault_public_fqdn
  token          = data.terraform_remote_state.tcm.outputs.hcp_vault_root_token
}