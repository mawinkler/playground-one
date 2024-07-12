# #############################################################################
# PGO User Group
# #############################################################################
resource "aws_iam_group" "pgo_group" {
  name = "${var.environment}-pgo-${random_string.suffix.result}"
  path = "/users/"
}

resource "aws_iam_group_policy_attachment" "pgo_group_ec2_policy" {
  group      = aws_iam_group.pgo_group.id
  policy_arn = aws_iam_policy.pgo_policy_ec2.arn
}

resource "aws_iam_group_policy_attachment" "pgo_group_ecs_policy" {
  group      = aws_iam_group.pgo_group.id
  policy_arn = aws_iam_policy.pgo_policy_ecs.arn
}

resource "aws_iam_group_policy_attachment" "pgo_group_eks_policy" {
  group      = aws_iam_group.pgo_group.id
  policy_arn = aws_iam_policy.pgo_policy_eks.arn
}

resource "aws_iam_group_policy_attachment" "pgo_group_iam_policy" {
  group      = aws_iam_group.pgo_group.id
  policy_arn = aws_iam_policy.pgo_policy_iam.arn
}

resource "aws_iam_group_policy_attachment" "pgo_group_kms_policy" {
  group      = aws_iam_group.pgo_group.id
  policy_arn = aws_iam_policy.pgo_policy_kms.arn
}

resource "aws_iam_group_policy_attachment" "pgo_group_lamda_policy" {
  group      = aws_iam_group.pgo_group.id
  policy_arn = aws_iam_policy.pgo_policy_lambda.arn
}

resource "aws_iam_group_policy_attachment" "pgo_group_rds_policy" {
  group      = aws_iam_group.pgo_group.id
  policy_arn = aws_iam_policy.pgo_policy_rds.arn
}

resource "aws_iam_group_policy_attachment" "pgo_group_s3_policy" {
  group      = aws_iam_group.pgo_group.id
  policy_arn = aws_iam_policy.pgo_policy_s3.arn
}

resource "aws_iam_group_policy_attachment" "pgo_group_svc_policy" {
  group      = aws_iam_group.pgo_group.id
  policy_arn = aws_iam_policy.pgo_policy_svc.arn
}
