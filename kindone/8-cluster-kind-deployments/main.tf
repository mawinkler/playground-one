data "terraform_remote_state" "kind" {
  backend = "local"

  config = {
    path = "../4-cluster-kind/terraform.tfstate"
  }
}

module "container_security" {
  count = var.container_security ? 1 : 0

  source         = "./container_security"
  environment    = var.environment
  cluster_name   = data.terraform_remote_state.kind.outputs.cluster_name
  cluster_policy = var.cluster_policy
  api_key        = var.api_key

  providers = {
    restapi.container_security = restapi.container_security
  }
}

module "calico" {
  count = var.calico ? 1 : 0

  source    = "./calico"
  namespace = "tigera-operator"
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
  namespace              = "prometheus"
  grafana_admin_password = var.grafana_admin_password
}
