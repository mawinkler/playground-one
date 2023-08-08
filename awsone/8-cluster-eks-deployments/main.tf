module "container_security" {
  source           = "./container_security"
  environment      = var.environment
  cluster_policy   = var.cluster_policy
  cloud_one_region = var.cloud_one_region
  api_key          = var.api_key
}

# module "victims" {
#   source      = "./victims"
#   environment = var.environment
#   access_ip   = var.access_ip
#   namespace   = "victims"
# }

module "trivy" {
  source      = "./trivy"
  environment = var.environment
  namespace   = "trivy-system"
}

# module "goat" {
#   source      = "./goat"
#   environment = var.environment
#   access_ip   = var.access_ip
#   namespace   = "goat"
# }
