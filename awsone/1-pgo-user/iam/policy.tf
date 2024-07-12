# #############################################################################
# PGO Policies
# #############################################################################
resource "aws_iam_policy" "pgo_policy_ec2" {
  name        = "${var.environment}-pgo-ec2-${random_string.suffix.result}"
  description = "PGO Policy for EC2"
  policy      = local.policy_ec2
}

resource "aws_iam_policy" "pgo_policy_iam" {
  name        = "${var.environment}-pgo-iam-${random_string.suffix.result}"
  description = "PGO Policy for IAM"
  policy      = local.policy_iam
}

resource "aws_iam_policy" "pgo_policy_svc" {
  name        = "${var.environment}-pgo-svc-${random_string.suffix.result}"
  description = "PGO Policy for other services"
  policy      = local.policy_svc
}
