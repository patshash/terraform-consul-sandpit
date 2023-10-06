data "terraform_remote_state" "tcm" {
  backend = "local"

  config = {
    path = "../../../terraform.tfstate"
  }
}

// hcp vault

module "vault" {
  source = "./modules/vault"
  providers = {
    vault.hcp               = vault.hcp
   } 

}

// fake-service

module "fake-service" {
  source = "./modules/fake-service"
  providers = {
    kubernetes.eks           = kubernetes.eks
    consul.hcp               = consul.hcp
    vault.hcp               = vault.hcp
  }
  
  consul_addr   = data.terraform_remote_state.tcm.outputs.hcp_consul_public_fqdn
  consul_token  = data.terraform_remote_state.tcm.outputs.hcp_consul_root_token
  vault_addr    = data.terraform_remote_state.tcm.outputs.hcp_vault_public_fqdn
  vault_token   = data.terraform_remote_state.tcm.outputs.hcp_vault_root_token

  depends_on = [ 
    module.vault 
  ]
}