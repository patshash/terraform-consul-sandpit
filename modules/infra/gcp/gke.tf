# Enable Kubernetes Engine API service
resource "google_project_service" "project" {
  service                     = "container.googleapis.com"
  disable_dependent_services  = true
}

module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google"
  version                = "23.3.0"

  project_id             = var.project_id
  name                   = var.deployment_id
  region                 = var.region
  regional               = true
  network                = module.vpc.network_name
  subnetwork             = module.vpc.subnets_names[0]
  ip_range_pods          = "gke-pods"
  ip_range_services      = "gke-services"
  create_service_account = true

  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      min_count                 = 1
      max_count                 = 2
      max_pods_per_node	        = 16
      auto_repair               = true
      auto_upgrade              = true
    },
  ]

  depends_on = [ 
    google_project_service.project 
  ]
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.deployment_id} --region ${var.region}"
  }

  depends_on = [
    module.gke
  ]
}