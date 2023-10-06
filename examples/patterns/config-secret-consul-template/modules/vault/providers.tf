terraform {
  required_providers {
    vault = {
      configuration_aliases = [ vault.hcp ]
    }
  }
}