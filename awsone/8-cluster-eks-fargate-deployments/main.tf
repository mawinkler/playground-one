data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../4-cluster-eks-fargate/terraform.tfstate"
  }
}

# module "container_security" {
#   count = var.container_security ? 1 : 0

#   source         = "./container_security"
#   environment    = var.environment
#   cluster_arn    = data.terraform_remote_state.eks.outputs.cluster_arn
#   cluster_name   = data.terraform_remote_state.eks.outputs.cluster_name
#   cluster_policy = var.cluster_policy
#   api_key        = var.api_key
#   group_id       = var.group_id

#   providers = {
#     restapi.container_security = restapi.container_security
#   }
# }

module "vision_one" {
  count = var.container_security ? 1 : 0

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
