data "terraform_remote_state" "tcm" {
  backend = "local"

  config = {
    path = "../../../terraform.tfstate"
  }
}

module "transit" {
  source = "./modules/transit"
}

module "onboarding" {
  source = "./modules/onboarding"
  count = var.test_units

  deployment_id = data.terraform_remote_state.tcm.outputs.deployment_id
  transit_path  = module.transit.path
  
  test_id       = "${var.test_prefix}-${format("%04d", count.index + 1)}"
  test_file     = var.test_file
}

module "encryption-processing" {
  source = "./modules/encryption-processing"
  count = var.test_units

  deployment_id = data.terraform_remote_state.tcm.outputs.deployment_id
  transit_path = module.transit.path
  vault_addr   = data.terraform_remote_state.tcm.outputs.hcp_vault_public_fqdn
  vault_token  = data.terraform_remote_state.tcm.outputs.hcp_vault_root_token

  test_id      = "${var.test_prefix}-${format("%04d", count.index + 1)}"
  test_file    = var.test_file

  depends_on = [ 
    module.onboarding 
  ]
}