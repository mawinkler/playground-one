data "terraform_remote_state" "kind" {
  backend = "local"

  config = {
    path = "../4-cluster-kind/terraform.tfstate"
  }
}


module "container_security" {
  count = var.container_security ? 1 : 0

  source           = "./container_security"
  environment      = var.environment
  cluster_name     = data.terraform_remote_state.kind.outputs.cluster_name
  cluster_policy   = var.cluster_policy
  api_key          = var.api_key
  registration_key = var.registration_key
  group_id         = var.group_id

  providers = {
    restapi.container_security = restapi.container_security
  }
}

module "vision_one" {
  count = var.container_security ? 0 : 0

  source                  = "./vision_one"
  environment             = var.environment
  cluster_name            = data.terraform_remote_state.kind.outputs.cluster_name
  cluster_policy          = var.cluster_policy
  cluster_policy_operator = var.cluster_policy_operator
  group_id                = var.group_id

  providers = {
    restapi.container_security   = restapi.container_security
    visionone.container_security = visionone.container_security
  }
}

module "calico" {
  count = var.calico ? 1 : 0

  source    = "./calico"
  namespace = "tigera-operator"
}

module "metallb" {
  count = var.metallb ? 1 : 0

  source    = "./metallb"
  namespace = "metallb-system"
}

module "trivy" {
  count = var.trivy ? 1 : 0

  source      = "./trivy"
  environment = var.environment
  namespace   = "trivy-system"
}

module "prometheus" {
  depends_on = [module.metallb]
  count      = var.prometheus ? 1 : 0

  source                 = "./prometheus"
  environment            = var.environment
  namespace              = "prometheus"
  grafana_admin_password = var.grafana_admin_password
}

module "pgoweb" {
  depends_on = [module.metallb]
  count      = var.pgoweb ? 1 : 0

  source         = "./pgoweb"
  namespace      = "pgoweb"
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  api_key        = var.api_key
}

module "argocd" {
  depends_on = [module.metallb]
  count      = var.argocd ? 1 : 0

  source       = "./argocd"
  namespace    = "argocd"
  admin_secret = var.argocd_admin_secret
  # aws_access_key = var.aws_access_key
  # aws_secret_key = var.aws_secret_key
  # api_key = var.api_key
}
