# // enable google cloud platform (gcp) redis api service

# resource "google_project_service" "redis" {
#   service                     = "redis.googleapis.com"
#   disable_dependent_services  = true
# }

# module "memorystore" {
#   source                  = "terraform-google-modules/memorystore/google"

#   name                    = "payments-queue"
#   project                 = var.project_id
#   authorized_network      = var.vpc_name
#   enable_apis             = "true"
#   memory_size_gb          = "1"
#   tier                    = "BASIC"
#   transit_encryption_mode	= "DISABLED"

#   depends_on = [
#     google_project_service.redis
#   ]
# }