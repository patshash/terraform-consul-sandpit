resource "local_file" "eks-splunk-enterprise-helm-values" {
  content = templatefile("${path.root}/examples/templates/splunk-enterprise-helm.yml", {
    })
  filename = "${path.module}/eks-splunk-enterprise-helm-values.yml.tmp"
}

# splunk operator & enterprise
resource "helm_release" "splunk-enterprise" {
  name          = "${var.deployment_name}-splunk-enterprise"
  chart         = "splunk-enterprise"
  repository    = "https://splunk.github.io/splunk-operator"
  version       = var.helm_chart_version
  namespace     = "splunk"
  timeout       = "300"
  wait          = true
  values        = [
    local_file.eks-splunk-enterprise-helm-values.content
  ]

  depends_on    = [
    kubernetes_namespace.splunk
  ]
}