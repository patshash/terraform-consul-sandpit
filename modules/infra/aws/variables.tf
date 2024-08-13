variable "region" {
  description = "AWS region"
  type        = string
}

variable "deployment_id" {
  description = "Deployment id"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

# variable "public_subnets" {
#   description = "Public subnets"
#   type        = list
# }

# variable "private_subnets" {
#   description = "Private subnets"
#   type        = list
# }

variable "eks_cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "eks_worker_instance_type" {
  description = "EKS worker nodes instance type"
  type        = string
}

variable "eks_worker_capacity_type" {
  description = "EKS worker nodes capacity type"
  type        = string
}

variable "eks_worker_desired_capacity" {
  description = "EKS worker nodes desired capacity"
  type        = number
}

variable "aws_efs_csi_driver_version" {
  description = "EKS EFS CSI Driver Addon version to install"
  type        = string
  default     = "v2.0.6-eksbuild.1"
}

variable "hcp_hvn_provider_account_id" {
  description = "HCP HVN provider account id"
  type        = string
}

variable "hcp_hvn_cidr" {
  description = "HCP HVN cidr"
  type        = string
}

variable "consul_serf_lan_port" {
  description = "Consul serf lan port"
  type        = number  
}