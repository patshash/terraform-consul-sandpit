resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
  description = "transit secret engine mount for encryption service"

#   options = {
#     convergent_encryption = false
#   }
}