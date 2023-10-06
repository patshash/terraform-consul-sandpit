variable "deployment_id" {
  description = "Deployment id"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = ""
}

variable "key_pair_key_name" {
  description = "Key pair name"
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "eks_cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "eks_cluster_service_cidr" {
  description = "EKS cluster service cidr"
  type        = string
}

variable "eks_worker_instance_type" {
  description = "EKS worker nodes instance type"
  type        = string
}

variable "eks_worker_desired_capacity" {
  description = "EKS worker nodes desired capacity"
  type        = number
}