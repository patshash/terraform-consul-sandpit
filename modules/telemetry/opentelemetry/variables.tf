variable "deployment_name" {
  description = "deployment name to prefix resources"
  type        = string
}

variable "namespace" {
  description = "kubernetes namespace"
  type        = string
}

variable "helm_chart_version" {
  description = "helm chart version"
  type        = string
}

variable "collector_name" {
  description = "collector name"
  type        = string
}

variable "consul_platform_type" {
  description = "consul platform type"
  validation {
    condition = var.consul_platform_type == "hcp" || var.consul_platform_type == "self-managed"
    error_message = "value must be one of 'hcp' or 'self-managed'."
  }
}

variable "consul_token" {
  description = "consul acl token"
  type = string
}

variable "prometheus_remote_write_endpoint" {
  description = "prometheus remote write endpoint"
  type        = string
}

variable "splunk_hec_endpoint" {
  description = "splunk hec endpoint"
  type        = string
}

variable "splunk_hec_token" {
  description = "splunk hec token"
  type        = string
}