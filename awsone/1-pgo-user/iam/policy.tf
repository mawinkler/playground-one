# #############################################################################
# PGO Policies
# #############################################################################
resource "aws_iam_policy" "pgo_policy_ec2" {
  name        = "${var.environment}-pgo-ec2-${random_string.suffix.result}"
  description = "PGO Policy for EC2"
  policy      = local.policy_ec2
}

resource "aws_iam_policy" "pgo_policy_ecs" {
  name        = "${var.environment}-pgo-ecs-${random_string.suffix.result}"
  description = "PGO Policy for ECS"
  policy      = local.policy_ecs
}

resource "aws_iam_policy" "pgo_policy_eks" {
  name        = "${var.environment}-pgo-eks-${random_string.suffix.result}"
  description = "PGO Policy for EKS"
  policy      = local.policy_eks
}

resource "aws_iam_policy" "pgo_policy_iam" {
  name        = "${var.environment}-pgo-iam-${random_string.suffix.result}"
  description = "PGO Policy for IAM"
  policy      = local.policy_iam
}

resource "aws_iam_policy" "pgo_policy_kms" {
  name        = "${var.environment}-pgo-kms-${random_string.suffix.result}"
  description = "PGO Policy for KMS"
  policy      = local.policy_kms
}

resource "aws_iam_policy" "pgo_policy_lambda" {
  name        = "${var.environment}-pgo-lambda-${random_string.suffix.result}"
  description = "PGO Policy for Lambda"
  policy      = local.policy_lambda
}

resource "aws_iam_policy" "pgo_policy_rds" {
  name        = "${var.environment}-pgo-rds-${random_string.suffix.result}"
  description = "PGO Policy for RDS"
  policy      = local.policy_rds
}

resource "aws_iam_policy" "pgo_policy_s3" {
  name        = "${var.environment}-pgo-s3-${random_string.suffix.result}"
  description = "PGO Policy for S3"
  policy      = local.policy_s3
}

resource "aws_iam_policy" "pgo_policy_svc" {
  name        = "${var.environment}-pgo-svc-${random_string.suffix.result}"
  description = "PGO Policy for other services"
  policy      = local.policy_svc
}
