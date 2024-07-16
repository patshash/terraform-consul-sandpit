variable "deployment_id" {
  description = "deployment id"
  type        = string
}

variable "vault_addr" {
  type    = string
}

variable "vault_namespace" {
  type    = string
  default = "admin"
}

variable "vault_token" {
  type    = string
}

variable "transit_path" {
  type    = string
}

variable "test_id" {
  type    = string
}

variable "test_file" {
  type = string
}