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

resource "aws_iam_group_policy_attachment" "pgo_group_iam_policy" {
  group      = aws_iam_group.pgo_group.id
  policy_arn = aws_iam_policy.pgo_policy_iam.arn
}

resource "aws_iam_group_policy_attachment" "pgo_group_svc_policy" {
  group      = aws_iam_group.pgo_group.id
  policy_arn = aws_iam_policy.pgo_policy_svc.arn
}
