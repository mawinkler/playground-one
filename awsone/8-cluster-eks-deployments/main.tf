module "container_security" {
  count = var.container_security ? 1 : 0

  source           = "./container_security"
  environment      = var.environment
  cluster_policy   = var.cluster_policy
  cloud_one_region = var.cloud_one_region
  api_key          = var.api_key

  providers = {
    restapi.clusters = restapi.clusters
  }
}

module "trivy" {
  count = var.trivy ? 1 : 0

  source      = "./trivy"
  environment = var.environment
  namespace   = "trivy-system"
}
