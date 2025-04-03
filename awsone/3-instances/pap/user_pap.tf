# #############################################################################
# IAM User (ASRM Scenario)
#   RDS Full Access
#   EC2 Instance start/stop
# #############################################################################
# Create IAM User
resource "aws_iam_user" "pgo_dbadmin" {
  name = "${var.environment}-dbadmin-${random_string.suffix.result}"

  tags = {
    Name          = "${var.environment}-iam-user"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
  }
}

# Create a User Group
resource "aws_iam_group" "pgo_developers" {
  name = "${var.environment}-dbadmins-${random_string.suffix.result}"
}

resource "aws_iam_group_membership" "pgo_dbadmin_membership" {
  name  = aws_iam_user.pgo_dbadmin.name
  users = [aws_iam_user.pgo_dbadmin.name]
  group = aws_iam_group.pgo_developers.name
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
    Configuration = "instances"
  }
}

# Attach AWS managed and custom Policies for the User group
resource "aws_iam_group_policy_attachment" "pgo_developers_rds_full_access" {
  policy_arn = data.aws_iam_policy.rds_full_access.arn
  group      = aws_iam_group.pgo_developers.name
}

resource "aws_iam_group_policy_attachment" "developers_ec2_instance_actions" {
  policy_arn = aws_iam_policy.ec2_instance_actions.arn
  group      = aws_iam_group.pgo_developers.name
}

# # Create Access key and Secret key
resource "aws_iam_access_key" "pgo_dbadmin_access_key" {
  user = aws_iam_user.pgo_dbadmin.name
}
