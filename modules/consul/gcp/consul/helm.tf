resource "local_file" "gke-consul-server-helm-values" {
  content = templatefile("${path.root}/examples/templates/gke-consul-server-helm.yml", {
    deployment_name       = "${var.deployment_name}-gcp"
    consul_version        = var.consul_version
    replicas              = var.replicas
    serf_lan_port         = var.serf_lan_port
    cloud                 = "gcp"
    })
  filename = "${path.module}/gke-server-helm-values.yml.tmp"
}

# consul server
resource "helm_release" "consul-server" {
  name          = "${var.deployment_name}-consul-server"
  chart         = "consul"
  repository    = "https://helm.releases.hashicorp.com"
  version       = var.helm_chart_version
  namespace     = "consul"
  timeout       = "300"
  wait_for_jobs = true
  values        = [
    local_file.gke-consul-server-helm-values.content
  ]

  depends_on    = [
    kubernetes_namespace.consul,
    kubernetes_secret.consul-ent-license,
  ]
}