# #############################################################################
# IAM User (ASRM Scenario)
#   RDS Full Access
#   EC2 Instance start/stop
# #############################################################################
# Create IAM User

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
    Configuration = "scenarios-zerotrust"
  }
}
