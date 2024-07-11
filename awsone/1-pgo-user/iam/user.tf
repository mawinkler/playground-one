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
resource "aws_iam_group_membership" "pgo_membership_ec2" {
  name  = "pgo-group-membership"
  users = [aws_iam_user.pgo_user.name]
  group = aws_iam_group.pgo_group_ec2.name
}

resource "aws_iam_group_membership" "pgo_membership_iam" {
  name  = "pgo-group-membership"
  users = [aws_iam_user.pgo_user.name]
  group = aws_iam_group.pgo_group_iam.name
}

resource "aws_iam_group_membership" "pgo_membership_svc" {
  name  = "pgo-group-membership"
  users = [aws_iam_user.pgo_user.name]
  group = aws_iam_group.pgo_group_svc.name
}
