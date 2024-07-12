# #############################################################################
# PGO User
# #############################################################################
resource "aws_iam_user" "pgo_user" {
  name = "${var.environment}-${random_string.suffix.result}"

  tags = {
    Name          = "${var.environment}-pgo-user-${random_string.suffix.result}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "user"
  }
}

resource "aws_iam_access_key" "pgo_access_key" {
  user = aws_iam_user.pgo_user.name
}

# Memberships
resource "aws_iam_group_membership" "pgo_membership" {
  name  = "pgo-group-membership"
  users = [aws_iam_user.pgo_user.name]
  group = aws_iam_group.pgo_group.name
}

# # User Policy Attachments
# resource "aws_iam_user_policy_attachment" "pgo_group_ec2_policy" {
#     user = aws_iam_user.pgo_user.name
#     policy_arn = aws_iam_policy.pgo_policy_ec2.arn
# }
# resource "aws_iam_user_policy_attachment" "pgo_group_iam_policy" {
#     user = aws_iam_user.pgo_user.name
#     policy_arn = aws_iam_policy.pgo_policy_iam.arn
# }
# resource "aws_iam_user_policy_attachment" "pgo_group_svc_policy" {
#     user = aws_iam_user.pgo_user.name
#     policy_arn = aws_iam_policy.pgo_policy_svc.arn
# }
