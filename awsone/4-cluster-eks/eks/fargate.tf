# #############################################################################
# Create Fargate Profile
# #############################################################################
module "fargate_profile" {
  count = var.create_fargate_profile ? 1 : 0

  source = "terraform-aws-modules/eks/aws//modules/fargate-profile"

  name         = "fargate-profile"
  cluster_name = module.eks.cluster_name

  subnet_ids = var.private_subnet_ids
  selectors = [{
    namespace = "fargate"
  }]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
