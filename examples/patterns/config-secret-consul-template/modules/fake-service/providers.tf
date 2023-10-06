terraform {
  required_providers {
    kubernetes = {
      configuration_aliases = [ kubernetes.eks ]
    }
    consul = {
      configuration_aliases = [ consul.hcp ]
    }
    vault = {
      configuration_aliases = [ vault.hcp ]
    }
  }
}