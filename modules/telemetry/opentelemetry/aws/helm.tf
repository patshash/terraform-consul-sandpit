resource "local_file" "eks-opentelemetry-collector-helm-values" {
  content = templatefile("${path.root}/modules/telemetry/examples/templates/opentelemetry-collector-helm.yml.tpl", {
    name         = "eks"
    hec_endpoint = var.splunk_hec_endpoint
    hec_token    = var.splunk_hec_token
    })
  filename = "${path.module}/eks-opentelemetry-collector-helm-values.yml.tmp"
}

# opentelemetry collector
resource "helm_release" "opentelemetry" {
  name          = "${var.deployment_name}-opentelemetry-collector"
  chart         = "opentelemetry-collector"
  repository    = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  version       = var.helm_chart_version
  namespace     = var.namespace
  timeout       = "300"
  wait          = true
  values        = [
    local_file.eks-opentelemetry-collector-helm-values.content
  ]
}