variable "deployment_name" {
  description = "Deployment name, used to prefix resources"
  type        = string
}

variable "helm_chart_version" {
  type        = string
  description = "Helm chart version"
}

variable "min_version" {
  description = "Consul minimum version"
  type        = string
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
}

variable "eks_kubernetes_api_endpoint" {
  description = "Kubernetes api endpoint"
  type        = string
}

variable "gke_kubernetes_api_endpoint" {
  description = "Kubernetes api endpoint"
  type        = string
}