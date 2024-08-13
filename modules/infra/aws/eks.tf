module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 20.0"

  cluster_name                    = var.deployment_id
  cluster_version                 = var.eks_cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = { 
  }

  eks_managed_node_groups = {
    "default_node_group" = {
      min_size               = 1
      max_size               = 4
      desired_size           = var.eks_worker_desired_capacity

      instance_types         = ["${var.eks_worker_instance_type}"]
      capacity_type          = var.eks_worker_capacity_type
      key_name               = module.key_pair.key_pair_name
      vpc_security_group_ids = [module.sg-consul.security_group_id, module.sg-telemetry.security_group_id, aws_security_group.efs.id]

      // extend default 20 gb volume size to 50 gb
      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 50
            volume_type = "gp3"
            delete_on_termination = true
          }
        }
      ]

      // required for aws-ebs-csi-driver
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
      }
    }
  }
}

resource "null_resource" "kubeconfig" {

  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
  }

  depends_on = [
    module.eks
  ]
}