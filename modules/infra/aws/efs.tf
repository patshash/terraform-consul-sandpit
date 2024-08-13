module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.44.0"

  #role_name_prefix                   = "VPC-CNI-IRSA"
  role_name                          = "efs-csi-irsa"
  attach_vpc_cni_policy              = true
  vpc_cni_enable_ipv4                = true
  attach_efs_csi_policy              = true

  oidc_providers = {
    efs = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}


resource "aws_security_group" "efs" {
  name        = "${module.eks.cluster_name} efs"
  description = "Allow traffic"
  vpc_id      =  module.vpc.vpc_id

  ingress {
    description      = "nfs"
    from_port        = 2049
    to_port          = 2049
    protocol         = "TCP"
    cidr_blocks      = [var.vpc_cidr]
  }
    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_efs_file_system" "kube" {
  creation_token = "eks-efs"
  encrypted      = true
  tags           = merge({
                    "eks_addon" = "aws-efs-csi-driver"
                    },
                    )
}

resource "aws_efs_mount_target" "efs_mt_0" {
  file_system_id  = aws_efs_file_system.kube.id
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.efs.id]
}


resource "aws_efs_mount_target" "efs_mt_1" {
  file_system_id  = aws_efs_file_system.kube.id
  subnet_id       = module.vpc.private_subnets[1]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "efs_mt_2" {
  file_system_id  = aws_efs_file_system.kube.id
  subnet_id       = module.vpc.private_subnets[2]
  security_groups = [aws_security_group.efs.id]
}


resource "kubectl_manifest" "efs_storage_class" {
  yaml_body = <<-YAML
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc1
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: ${aws_efs_file_system.kube.id}
  directoryPerms: "700"
  YAML

  depends_on = [
    aws_efs_file_system.kube
  ]
}

#v2.0.6-eksbuild.1
resource "aws_eks_addon" "aws_efs_csi_driver" {
  
  cluster_name  = module.eks.cluster_name
  addon_name    = "aws-efs-csi-driver"
  addon_version = "v2.0.6-eksbuild.1"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = module.vpc_cni_irsa.iam_role_arn

  configuration_values = jsonencode({
    controller = {
      tolerations : [
        {
          key : "system",
          operator : "Equal",
          value : "owned",
          effect : "NoSchedule"
        }
      ]
    }
  })

  preserve = true

  tags = {
    "eks_addon" = "aws-ebs-csi-driver"
  }
}

resource "aws_iam_policy" "node_efs_policy" {
  name        = "eks_node_efs-${module.eks.cluster_name}"
  path        = "/"
  description = "Policy for EFKS nodes to use EFS"

  policy = jsonencode({
    "Statement": [
        {
            "Action": [
                "elasticfilesystem:DescribeMountTargets",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:CreateAccessPoint",
                "elasticfilesystem:DeleteAccessPoint",
                "ec2:DescribeAvailabilityZones"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": ""
        }
    ],
    "Version": "2012-10-17"
}
  )
}