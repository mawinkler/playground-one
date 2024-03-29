# #############################################################################
# Create IAM roles, admin and user
# #############################################################################
#
# EKS Cluster
#
module "allow_eks_access_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.32.1"

  name          = "${module.eks.cluster_name}-allow-eks-access"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = {
    Name          = "${module.eks.cluster_name}-allow-eks-access"
    Environment   = "${module.eks.cluster_name}"
    Product       = "playground-one"
    Configuration = "eks-ec2"
  }
}

module "eks_admins_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.32.1"

  role_name         = "${module.eks.cluster_name}-eks-admin"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [module.allow_eks_access_iam_policy.arn]

  trusted_role_arns = [
    "arn:aws:iam::${var.vpc_owner_id}:root"
  ]

  tags = {
    Name          = "${module.eks.cluster_name}-iam-role-eks-admin"
    Environment   = "${module.eks.cluster_name}"
    Product       = "playground-one"
    Configuration = "eks-ec2"
  }
}

module "clusteradmin_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.32.1"

  name                          = "${module.eks.cluster_name}-clusteradmin"
  create_iam_access_key         = false
  create_iam_user_login_profile = false

  force_destroy = true
}

module "allow_assume_eks_admins_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.32.1"

  name          = "${module.eks.cluster_name}-allow-assume-eks-admin-iam-role"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = module.eks_admins_iam_role.iam_role_arn
      },
    ]
  })

  tags = {
    Name          = "${module.eks.cluster_name}-allow-eks-admin-assume-role"
    Environment   = "${module.eks.cluster_name}"
    Product       = "playground-one"
    Configuration = "eks-ec2"
  }
}

module "eks_admins_iam_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.32.1"

  name                              = "${module.eks.cluster_name}-eks-admin"
  attach_iam_self_management_policy = false
  create_group                      = true
  group_users                       = [module.clusteradmin_iam_user.iam_user_name]
  custom_group_policy_arns          = [module.allow_assume_eks_admins_iam_policy.arn]
}

#
# EC2 Autoscaler
#
# Policy
data "aws_iam_policy_document" "kubernetes_cluster_autoscaler" {
  count = var.autoscaler_enabled ? 1 : 0

  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

}

resource "aws_iam_policy" "kubernetes_cluster_autoscaler" {
  # depends_on  = [var.autoscaler_dependency]
  count = var.autoscaler_enabled ? 1 : 0

  name        = "${module.eks.cluster_name}-cluster-autoscaler"
  path        = "/"
  description = "Policy for cluster autoscaler service"

  policy = data.aws_iam_policy_document.kubernetes_cluster_autoscaler[0].json
}

# Role
data "aws_iam_policy_document" "kubernetes_cluster_autoscaler_assume" {
  count = var.autoscaler_enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]

    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${local.autoscaler_namespace}:${local.autoscaler_service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "kubernetes_cluster_autoscaler" {
  count = var.autoscaler_enabled ? 1 : 0

  name               = "${module.eks.cluster_name}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.kubernetes_cluster_autoscaler_assume[0].json
}

resource "aws_iam_role_policy_attachment" "kubernetes_cluster_autoscaler" {
  count = var.autoscaler_enabled ? 1 : 0

  role       = aws_iam_role.kubernetes_cluster_autoscaler[0].name
  policy_arn = aws_iam_policy.kubernetes_cluster_autoscaler[0].arn
}
