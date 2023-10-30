variable "deployment_name" {
  description = "deployment name to prefix resources"
  type        = string
}

variable "namespace" {
  description = "kubernetes namespace"
  type        = string
  default     = "telemetry"
}

variable "gcp_consul_token" {
  description = "consul acl token"
  type        = string
}

variable "splunk_operator_helm_chart_version" {
  description = "helm chart version"
  type        = string
}

variable "prometheus_helm_chart_version" {
  description = "helm chart version"
  type        = string
}

variable "grafana_helm_chart_version" {
  description = "helm chart version"
  type        = string
}

variable "opentelemetry_collector_helm_chart_version" {
  description = "helm chart version"
  type        = string
}
