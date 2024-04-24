# #############################################################################
# Create IAM roles, admin and user
# #############################################################################
#
# EKS Cluster
#
resource "aws_iam_role" "this" {
  name = "${var.environment}-cluster-access"

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
