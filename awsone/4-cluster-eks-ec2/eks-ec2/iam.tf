# #############################################################################
# Create IAM roles, admin and user
# #############################################################################
#
# EKS Cluster
#
resource "aws_iam_role" "cluster_access_role" {
  name = "${var.environment}-cluster-access-${random_string.suffix.result}"

  # Just using for this example
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "Example"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name          = "${var.environment}-eks-ec2-cluster-access-${random_string.suffix.result}"
    Environment   = "${var.environment}-eks-ec2-${random_string.suffix.result}"
    Product       = "playground-one"
    Configuration = "eks-ec2"
  }
}

# #
# # RDSec
# #
# resource "aws_iam_role" "rdsec_eks_role" {
#   # name = "${var.environment}-rdsec-cluster-access"
#   name = "RDSec-EKS-Readonly"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           "AWS": "arn:aws:iam::278722347474:role/RDSec-EKS-Readonly"
#         }
#       },
#     ]
#   })

#   tags = {
#     Name          = "${var.environment}-eks-ec2-rdsec-cluster-access-${random_string.suffix.result}"
#     Environment   = "${var.environment}-eks-ec2-${random_string.suffix.result}"
#     Product       = "playground-one"
#     Configuration = "eks-ec2"
#   }
# }

# data "aws_iam_policy_document" "rdsec_eks_policy_document" {

#   statement {
#     actions = [
#       "eks:DescribeCluster",
#       "eks:ListClusters"
#     ]
#     resources = [
#       "*",
#     ]
#     effect = "Allow"
#   }

# }

# resource "aws_iam_policy" "rdsec_eks_policy" {
#   name        = "${module.eks.cluster_name}-rdsec-cluster-access"
#   path        = "/"
#   description = "Policy for RDSec Cluster Access"

#   policy = data.aws_iam_policy_document.rdsec_eks_policy_document.json
# }

# resource "aws_iam_role_policy_attachment" "rdsec_eks_policy" {
#   count = var.autoscaler_enabled ? 1 : 0

#   role       = aws_iam_role.rdsec_eks_role.name
#   policy_arn = aws_iam_policy.rdsec_eks_policy.arn
# }

# resource "kubernetes_cluster_role_v1" "rdsec_eks_cluster_role" {
#   metadata {
#     name = "k8s-inventory-clusterrole"
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["pods", "nodes", "services"]
#     verbs      = ["get", "list", "watch"]
#   }

#   rule {
#     api_groups = ["networking.k8s.io", "extensions"]
#     resources  = ["ingresses"]
#     verbs      = ["get", "list", "watch"]
#   }
# }

# resource "kubernetes_cluster_role_binding_v1" "rdsec_eks_cluster_role_binding" {
#   metadata {
#     name = "k8s-inventory-clusterrole"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "k8s-inventory-clusterrole"
#   }
#   subject {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "Group"
#     name      = "k8s-inventory-clusterrole"
#   }
# }

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
