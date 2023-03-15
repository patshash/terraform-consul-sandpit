module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "5.2.0"

  project_id   = var.project_id
  network_name = var.deployment_id

  subnets = [
    {
      subnet_name           = "private"
      subnet_ip             = var.private_subnets[0]
      subnet_region         = var.region
    },
  ]
  secondary_ranges = {
    private = [
      {
        range_name    = "gke-pods"
        ip_cidr_range = var.gke_pod_subnet
      },
      {
        range_name    = "gke-services"
        ip_cidr_range = var.gke_cluster_service_cidr
      },
    ]
  }
}