// splunk enterprise in aws

module "splunk-enterprise-aws" {
  source = "./splunk/aws"
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
   }

  deployment_name    = var.deployment_name
  namespace          = var.namespace
  helm_chart_version = var.splunk_operator_helm_chart_version
}

//opentelemetry collector in aws

module "opentelemetry-aws" {
  source = "./opentelemetry/aws"
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
   }

  deployment_name     = var.deployment_name
  namespace           = var.namespace
  helm_chart_version  = var.opentelemetry_collector_helm_chart_version
  splunk_hec_endpoint = module.splunk-enterprise-aws.public_fqdn
  splunk_hec_token    = module.splunk-enterprise-aws.hec_token
}