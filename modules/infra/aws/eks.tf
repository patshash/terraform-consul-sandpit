module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.26.3"

  cluster_name                    = var.deployment_id
  cluster_version                 = var.eks_cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_service_ipv4_cidr       = var.eks_cluster_service_cidr

  cluster_addons = {
    aws-ebs-csi-driver = { // for splunk operator persistent volume claim (pvc)
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  eks_managed_node_group_defaults = { 
  }

  eks_managed_node_groups = {
    "default_node_group" = {
      min_size               = 1
      max_size               = 3
      desired_size           = var.eks_worker_desired_capacity

      instance_types         = ["${var.eks_worker_instance_type}"]
      capacity_type          = var.eks_worker_capacity_type
      key_name               = module.key_pair.key_pair_name
      vpc_security_group_ids = [module.sg-consul.security_group_id, module.sg-telemetry.security_group_id]
    }
  }
}

resource "null_resource" "kubeconfig" {

  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_id}"
  }

  depends_on = [
    module.eks
  ]
}

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"
  
  role_name             = "ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}