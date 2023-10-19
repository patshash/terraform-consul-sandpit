resource "local_file" "opentelemetry-collector-helm-values" {
  content = templatefile("${path.root}/modules/telemetry/examples/templates/opentelemetry-collector-helm.yml.tpl", {
    name         = var.collector_name
    hec_endpoint = var.splunk_hec_endpoint
    hec_token    = var.splunk_hec_token
    })
  filename = "${path.module}/${var.collector_name}-opentelemetry-collector-helm-values.yml.tmp"
}

# opentelemetry collector
resource "helm_release" "opentelemetry" {
  name             = "${var.deployment_name}-opentelemetry-collector"
  chart            = "opentelemetry-collector"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = true
  timeout          = "300"
  wait             = true
  values           = [
    local_file.opentelemetry-collector-helm-values.content
  ]
}