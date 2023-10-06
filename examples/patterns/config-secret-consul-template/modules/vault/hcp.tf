// enable kv v2 secrets engine

resource "vault_mount" "kvv2" {
  provider = vault.hcp

  path        = "app"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}