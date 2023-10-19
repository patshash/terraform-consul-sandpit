variable "deployment_name" {
  description = "deployment name to prefix resources"
  type        = string
}

variable "namespace" {
  description = "kubernetes namespace"
  type        = string
  default     = "telemetry"
}

variable "splunk_operator_helm_chart_version" {
  description = "helm chart version"
  type        = string
}

variable "opentelemetry_collector_helm_chart_version" {
  description = "helm chart version"
  type        = string
}
