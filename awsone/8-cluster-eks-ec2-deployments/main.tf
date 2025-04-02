data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../4-cluster-eks-ec2/terraform.tfstate"
  }
}

module "container_security" {
  count = var.container_security ? 1 : 0

  source         = "./container_security"
  environment    = var.environment
  cluster_arn    = data.terraform_remote_state.eks.outputs.cluster_arn
  cluster_name   = data.terraform_remote_state.eks.outputs.cluster_name
  cluster_policy = var.cluster_policy
  api_key        = var.api_key
  group_id       = var.group_id

  providers = {
    restapi.container_security = restapi.container_security
  }
}

module "vision_one" {
  count = var.container_security ? 0 : 0

  source                  = "./vision_one"
  environment             = var.environment
  cluster_arn             = data.terraform_remote_state.eks.outputs.cluster_arn
  cluster_name            = data.terraform_remote_state.eks.outputs.cluster_name
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

module "istio" {
  count = var.istio ? 1 : 0

  source            = "./istio"
  environment       = var.environment
  namespace_base    = "istio-system"
  namespace_ingress = "istio-ingress"
}

module "metrics" {
  source = "./metrics-server"
}

module "pgoweb" {
  count = var.pgoweb ? 1 : 0

  source    = "./pgoweb"
  namespace = "pgoweb"
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  access_ip = var.access_ip
  api_key = var.api_key
}
