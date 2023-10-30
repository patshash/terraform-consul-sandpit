// opentelemetry collector on hashicorp cloud platform (hcp) consul clusters 

resource "local_file" "opentelemetry-collector-hcp-helm-values" {
  count = var.consul_platform_type == "hcp" ? 1 : 0

  content = templatefile("${path.root}/modules/telemetry/examples/templates/opentelemetry-collector-${var.consul_platform_type}-helm.yml.tpl", {
    name                             = var.collector_name
    hec_endpoint                     = var.splunk_hec_endpoint
    hec_token                        = var.splunk_hec_token
    })
  filename = "${path.module}/${var.collector_name}-opentelemetry-collector-${var.consul_platform_type}-helm-values.yml.tmp"
}

resource "helm_release" "opentelemetry-hcp" {
  count = var.consul_platform_type == "hcp" ? 1 : 0

  name             = "${var.deployment_name}-opentelemetry-collector"
  chart            = "opentelemetry-collector"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = true
  timeout          = "300"
  wait             = true
  values           = [
    local_file.opentelemetry-collector-hcp-helm-values[0].content
  ]
}

// opentelemetry collector on self-managed consul clusters 

resource "local_file" "opentelemetry-collector-self-managed-helm-values" {
  count = var.consul_platform_type == "self-managed" ? 1 : 0

  content = templatefile("${path.root}/modules/telemetry/examples/templates/opentelemetry-collector-${var.consul_platform_type}-helm.yml.tpl", {
    name                             = var.collector_name
    consul_token                     = var.consul_token
    prometheus_remote_write_endpoint = var.prometheus_remote_write_endpoint
    hec_endpoint                     = var.splunk_hec_endpoint
    hec_token                        = var.splunk_hec_token
    })
  filename = "${path.module}/${var.collector_name}-opentelemetry-collector-${var.consul_platform_type}-helm-values.yml.tmp"
}

resource "helm_release" "opentelemetry-self-managed" {
  count = var.consul_platform_type == "self-managed" ? 1 : 0

  name             = "${var.deployment_name}-opentelemetry-collector"
  chart            = "opentelemetry-collector"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = true
  timeout          = "300"
  wait             = true
  values           = [
    local_file.opentelemetry-collector-self-managed-helm-values[0].content
  ]
}