resource "local_file" "eks-grafana-helm-values" {
  content = templatefile("${path.root}/modules/telemetry/examples/templates/grafana-helm.yml.tpl", {
    deployment_name = var.deployment_name
    admin_password = var.admin_password
    })
  filename = "${path.module}/eks-grafana-helm-values.yml.tmp"
}

# grafana collector
resource "helm_release" "grafana" {
  name             = "${var.deployment_name}-grafana"
  chart            = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = true
  timeout          = "300"
  wait             = true
  values           = [
    local_file.eks-grafana-helm-values.content
  ]
}