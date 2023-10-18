// splunk enterprise in aws

module "splunk-enterprise-aws" {
  source = "./splunk/aws"
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
   }

  deployment_name    = var.deployment_name
  helm_chart_version = var.splunk_operator_helm_chart_version
}