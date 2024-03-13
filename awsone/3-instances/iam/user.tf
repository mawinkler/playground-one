# #############################################################################
# IAM User (ASRM Scenario)
#   RDS Full Access
#   EC2 Instance start/stop
# #############################################################################
# Create IAM User
resource "aws_iam_user" "pgo_dbadmin" {
  count = var.create_attackpath ? 1 : 0

  name = "${var.environment}-dbadmin-${random_string.suffix.result}"

  tags = {
    Name          = "${var.environment}-iam-user"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }
}

# Create a User Group
resource "aws_iam_group" "pgo_developers" {
  count = var.create_attackpath ? 1 : 0

  name = "${var.environment}-dbadmins-${random_string.suffix.result}"
}

resource "aws_iam_group_membership" "pgo_dbadmin_membership" {
  count = var.create_attackpath ? 1 : 0

  name  = aws_iam_user.pgo_dbadmin[0].name
  users = [aws_iam_user.pgo_dbadmin[0].name]
  group = aws_iam_group.pgo_developers[0].name
}

# Create AWS-managed policy and Custom policy And attach user group
# rds full
data "aws_iam_policy" "rds_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

# ec2 custom
data "aws_iam_policy_document" "ec2_instance_actions" {
  statement {
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances",
    ]

    resources = [
      "arn:aws:ec2:*:*:instance/*",
    ]
  }
}

resource "aws_iam_policy" "ec2_instance_actions" {
  name   = "${var.environment}-ec2-instance-actions-${random_string.suffix.result}"
  policy = data.aws_iam_policy_document.ec2_instance_actions.json

  tags = {
    Name          = "${var.environment}-ec2-instance-actions-policy"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }
}

# Attach AWS managed and custom Policies for the User group
resource "aws_iam_group_policy_attachment" "pgo_developers_rds_full_access" {
  count = var.create_attackpath ? 1 : 0

  policy_arn = data.aws_iam_policy.rds_full_access.arn
  group      = aws_iam_group.pgo_developers[0].name
}

resource "aws_iam_group_policy_attachment" "developers_ec2_instance_actions" {
  count = var.create_attackpath ? 1 : 0

  policy_arn = aws_iam_policy.ec2_instance_actions.arn
  group      = aws_iam_group.pgo_developers[0].name
}

# # Create Access key and Secret key
resource "aws_iam_access_key" "pgo_dbadmin_access_key" {
  count = var.create_attackpath ? 1 : 0

  user = aws_iam_user.pgo_dbadmin[0].name
}
