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