// hashicorp cloud platform (hcp) variables

variable "hcp_region" {
  description = "HCP region"
  type        = string
  default     = ""
}

variable "hcp_client_id" {
  description = "HCP client id"
  type        = string
  default     = ""
}

variable "hcp_client_secret" {
  description = "HCP client secret"
  type        = string
  default     = ""
}

// amazon web services (aws) variables

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = ""
}

variable "aws_eks_cluster_version" {
  description = "AWS EKS cluster version"
  type        = string
  default     = "1.24"
}

variable "aws_eks_cluster_service_cidr" {
  description = "AWS EKS cluster service cidr"
  type        = string
  default     = "172.20.0.0/18"
}

variable "aws_eks_worker_instance_type" {
  description = "AWS EKS EC2 worker node instance type"
  type        = string
  default     = "m5.large"
}

variable "aws_eks_worker_desired_capacity" {
  description = "AWS EKS desired worker capacity in the autoscaling group"
  type        = number
  default     = 2
}

// google cloud platform (gcp) variables

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = ""
}

// hashicorp self-managed consul variables

variable "consul_replicas" {
  description = "Number of Consul replicas"
  type        = number
  default     = 1
}