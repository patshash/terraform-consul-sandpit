terraform {
  required_providers {
    kubernetes = {
      configuration_aliases = [ kubernetes.eks, kubernetes.gke]
    }
    helm = {
      configuration_aliases = [ helm.eks, helm.gke ]
    }
  }
}