data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../4-cluster-eks/terraform.tfstate"
  }
}

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

module "calico" {
  count = var.calico ? 1 : 0

  source      = "./calico"
  namespace   = "tigera-operator"
}

module "trivy" {
  count = var.trivy ? 1 : 0

  source      = "./trivy"
  environment = var.environment
  namespace   = "trivy-system"
}

module "prometheus" {
  count = var.prometheus ? 1 : 0

  source                 = "./prometheus"
  environment            = var.environment
  access_ip              = var.access_ip
  namespace              = "prometheus"
  grafana_admin_password = var.grafana_admin_password
}
