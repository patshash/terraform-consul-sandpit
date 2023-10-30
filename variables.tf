// generic variables

variable "deployment_name" {
  description = "deployment name to prefix resources"
  type        = string
  default     = "sandpit"
}

variable "consul_version" {
  description = "consul version"
  type        = string
  default     = "1.16.2"
}

// enable & disable modules

variable "enable_hcp_vault" {
  description = "deploy vault on hashiCorp cloud platform (hcp)"
  type        = bool
  default     = false
}

variable "enable_telemetry" {
  description = "deploy telemetry services"
  type        = bool
  default     = false
}

// hashicorp cloud platform (hcp) variables

variable "hcp_client_id" {
  description = "hcp client id"
  type        = string
  default     = ""
}

variable "hcp_client_secret" {
  description = "hcp client secret"
  type        = string
  default     = ""
}

variable "hcp_hvn_cidr" {
  description = "hcp hvn cidr"
  type        = string
  default     = "172.25.16.0/20"
}

variable "hcp_consul_tier" {
  description = "hcp consul cluster tier"
  type        = string
  default     = "development"
}

variable "hcp_vault_tier" {
  description = "hcp vault cluster tier"
  type        = string
  default     = "dev"
}

// amazon web services (aws) variables

variable "aws_region" {
  description = "aws region"
  type        = string
  default     = ""
}

variable "aws_vpc_cidr" {
  description = "aws vpc cidr"
  type        = string
  default     = "10.200.0.0/16"
}

variable "aws_private_subnets" {
  description = "aws private subnets"
  type        = list
  default     = ["10.200.20.0/24", "10.200.21.0/24", "10.200.22.0/24"]
}

variable "aws_public_subnets" {
  description = "aws public subnets"
  type        = list
  default     = ["10.200.10.0/24", "10.200.11.0/24", "10.200.12.0/24"]
}

variable "aws_eks_cluster_version" {
  description = "aws eks cluster version"
  type        = string
  default     = "1.27"
}

variable "aws_eks_cluster_service_cidr" {
  description = "aws eks cluster service cidr"
  type        = string
  default     = "172.20.0.0/18"
}

variable "aws_eks_worker_instance_type" {
  description = "aws eks ec2 worker node instance type"
  type        = string
  default     = "m6i.large"
}

variable "aws_eks_worker_desired_capacity" {
  description = "aws eks desired worker autoscaling group capacity"
  type        = number
  default     = 3
}

// google cloud platform (gcp) variables

variable "gcp_region" {
  description = "gcp region"
  type        = string
  default     = ""
}

variable "gcp_project_id" {
  description = "gcp project id"
  type        = string
  default     = ""
}

variable "gcp_private_subnets" {
  description = "gcp private subnets"
  type        = list
  default     = ["10.210.20.0/24", "10.210.21.0/24", "10.210.22.0/24"]
}

variable "gcp_gke_pod_subnet" {
  description = "gcp gke pod subnet"
  type        = string
  default     = "10.211.20.0/23"
}

variable "gcp_gke_cluster_service_cidr" {
  description = "gcp gke cluster service cidr"
  type        = string
  default     = "172.20.0.0/18"
}

// hashicorp self-managed consul variables

variable "consul_helm_chart_version" {
  type        = string
  description = "helm chart version"
  default     = "1.2.2"
}

variable "consul_ent_license" {
  description = "consul enterprise license"
  type        = string
  default     = ""
}

variable "consul_replicas" {
  description = "consul replicas"
  type        = number
  default     = 1
}

variable "consul_serf_lan_port" {
  description = "consul serf lan port"
  type        = number
  default     = 9301
}

// telemetry variables

variable "splunk_operator_helm_chart_version" {
  description = "helm chart version"
  type        = string
  default     = "2.4.0"
}

variable "prometheus_helm_chart_version" {
  description = "helm chart version"
  type        = string
  default     = "25.2.0"
}

variable "grafana_helm_chart_version" {
  description = "helm chart version"
  type        = string
  default     = "6.61.1"
}

variable "opentelemetry_collector_helm_chart_version" {
  description = "helm chart version"
  type        = string
  default     = "0.72.0"
}
