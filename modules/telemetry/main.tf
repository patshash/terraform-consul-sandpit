// create gp3 as the default storage class for splunk and prometheus
resource "kubernetes_annotations" "gp2" {
  provider = kubernetes.eks
  
  annotations = {
    "storageclass.kubernetes.io/is-default-class" : "false"
  }
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }

  force = true
}

resource "kubernetes_storage_class" "ebs_csi_encrypted_gp3" {
  provider = kubernetes.eks

  metadata {
    name = "ebs-csi-encrypted-gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" : "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    fsType    = "ext4"
    encrypted = true
    type      = "gp3"
  }
}

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