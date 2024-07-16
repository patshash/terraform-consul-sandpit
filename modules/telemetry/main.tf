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

// prometheus in aws

module "prometheus-aws" {
  source = "./prometheus/aws"
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
   }

  deployment_name    = var.deployment_name
  namespace          = var.namespace
  helm_chart_version = var.prometheus_helm_chart_version
}

// granfana in aws

module "grafana-aws" {
  source = "./grafana/aws"
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
   }

  deployment_name    = var.deployment_name
  namespace          = var.namespace
  helm_chart_version = var.grafana_helm_chart_version
}

//opentelemetry collector in eks

module "opentelemetry-eks" {
  source = "./opentelemetry"
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
   }

  deployment_name           = var.deployment_name
  namespace                 = var.namespace
  collector_name            = "eks"
  helm_chart_version        = var.opentelemetry_collector_helm_chart_version
  consul_platform_type      = "hcp"
  consul_token              = "null"
  splunk_hec_endpoint       = module.splunk-enterprise-aws.public_fqdn
  splunk_hec_token          = module.splunk-enterprise-aws.hec_token
  prometheus_remote_write_endpoint = module.prometheus-aws.public_fqdn
}

//opentelemetry collector in gke

module "opentelemetry-gke" {
  source = "./opentelemetry"
  providers = {
    kubernetes = kubernetes.gke
    helm       = helm.gke
   }

  count = var.gcp_consul_token == "" ? 0 : 1

  deployment_name                  = var.deployment_name
  namespace                        = var.namespace
  collector_name                   = "gke"
  helm_chart_version               = var.opentelemetry_collector_helm_chart_version
  consul_platform_type             = "self-managed"
  consul_token                     = var.gcp_consul_token
  prometheus_remote_write_endpoint = module.prometheus-aws.public_fqdn
  splunk_hec_endpoint              = module.splunk-enterprise-aws.public_fqdn
  splunk_hec_token                 = module.splunk-enterprise-aws.hec_token
}