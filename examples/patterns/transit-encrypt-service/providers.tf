terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.21.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "~> 4.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.17.0"
    }
  }
}

provider "vault" {
  address         = data.terraform_remote_state.tcm.outputs.hcp_vault_public_fqdn
  token           = data.terraform_remote_state.tcm.outputs.hcp_vault_root_token
  skip_tls_verify = false
}

provider "aws" {
  region = data.terraform_remote_state.tcm.outputs.aws_region
}

data "aws_eks_cluster" "default" {
  name = data.terraform_remote_state.tcm.outputs.deployment_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.name]
    command     = "aws"
  }
}