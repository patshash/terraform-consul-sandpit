variable "region" {
  description = "GCP region"
  type        = string
}

variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "deployment_id" {
  description = "Deployment id"
  type        = string
}

variable "private_subnets" {
  description = "GCP private subnets"
  type        = list
}

variable "gke_pod_subnet" {
  description = "GCP pod subnet"
  type        = string
}

variable "gke_cluster_service_cidr" {
  description = "GCP GKE cluster service cidr"
  type        = string
}