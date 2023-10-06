terraform {
  required_providers {
    kubernetes = {
      configuration_aliases = [ kubernetes.eks, kubernetes.eks-hashicups, kubernetes.gke, kubernetes.gke-hashicups ]
    }
    helm = {
      configuration_aliases = [ helm.eks-hashicups, helm.gke-hashicups ]
    }
    consul = {
      configuration_aliases = [ consul.hcp, consul.gcp ]
    }
  }
}