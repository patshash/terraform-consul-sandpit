resource "local_file" "eks-prometheus-helm-values" {
  content = templatefile("${path.root}/modules/telemetry/examples/templates/prometheus-helm.yml.tpl", {
    })
  filename = "${path.module}/eks-prometheus-helm-values.yml.tmp"
}

# prometheus
resource "helm_release" "prometheus" {
  name             = "${var.deployment_name}-prometheus"
  chart            = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = true
  timeout          = "300"
  wait             = true
  values           = [
    local_file.eks-prometheus-helm-values.content
  ]
}