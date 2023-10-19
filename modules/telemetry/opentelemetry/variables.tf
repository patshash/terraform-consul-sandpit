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

variable "splunk_hec_endpoint" {
  description = "splunk hec endpoint"
  type        = string
}

variable "splunk_hec_token" {
  description = "splunk hec token"
  type        = string
}