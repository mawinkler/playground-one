data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../4-cluster-eks-fargate/terraform.tfstate"
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
