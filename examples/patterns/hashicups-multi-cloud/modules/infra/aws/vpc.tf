data "aws_subnets" "all" {
  filter {
    name   = "tag:Name"
    values = ["*${var.deployment_id}*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_security_groups" "consul" {
  filter {
    name   = "group-name"
    values = ["*consul*"]
  }
}

resource "aws_ec2_tag" "eks_deployment_id" {
  for_each = toset(data.aws_subnets.all.ids)

  resource_id = each.value
  key         = "kubernetes.io/cluster/${module.eks.cluster_id}"
  value       = "shared"
}