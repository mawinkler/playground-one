# #############################################################################
# Create Fargate Profile
# #############################################################################
module "fargate_profile" {
  count = var.create_fargate_profile ? 1 : 0

  source = "terraform-aws-modules/eks/aws//modules/fargate-profile"

  name            = "fargate-profile"
  cluster_name    = module.eks.cluster_name
  create_iam_role = true
  iam_role_name   = "${module.eks.cluster_name}-fargate-role"
  subnet_ids      = var.private_subnet_ids
  selectors = [
    {
      namespace = "fargate"
    }
  ]

  tags = {
    Name        = "${var.environment}-fargate-profile"
    Environment = "${var.environment}"
  }
  iam_role_tags = {
    Name        = "${var.environment}-fargate-profile"
    Environment = "${var.environment}"
  }
}
