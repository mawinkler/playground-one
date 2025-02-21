# #############################################################################
# IAM User (ASRM Scenario)
#   EC2 Instance start/stop
# #############################################################################
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
    Configuration = "satellite"
  }
}
