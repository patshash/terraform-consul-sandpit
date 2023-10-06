terraform {
  required_providers {
    kubernetes = {
      configuration_aliases = [ kubernetes.eks-hashicups, kubernetes.gke-hashicups ]
    }
    consul = {
      configuration_aliases = [ consul.hcp, consul.gcp ]
    }
  }
}