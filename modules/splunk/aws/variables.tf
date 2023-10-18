variable "deployment_name" {
  description = "deployment name to prefix resources"
  type        = string
}

variable "helm_chart_version" {
  type        = string
  description = "helm chart version"
}