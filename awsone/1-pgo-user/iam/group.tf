# EC2 Policy
resource "aws_iam_group" "pgo_group_ec2" {
    name = "${var.environment}-ec2-${random_string.suffix.result}"
    path = "/users/"
}

resource "aws_iam_group_policy" "pgo_group_ec2_policy" {
    name = "${var.environment}-ec2-${random_string.suffix.result}"
    group = aws_iam_group.pgo_group_ec2.id
    policy = local.policy_ec2
}

# IAM Policy
resource "aws_iam_group" "pgo_group_iam" {
    name = "${var.environment}-iam-${random_string.suffix.result}"
    path = "/users/"
}

resource "aws_iam_group_policy" "pgo_group_iam_policy" {
    name = "${var.environment}-iam-${random_string.suffix.result}"
    group = aws_iam_group.pgo_group_iam.id
    policy = local.policy_iam
}

# Other Services Policy
resource "aws_iam_group" "pgo_group_svc" {
    name = "${var.environment}-svc-${random_string.suffix.result}"
    path = "/users/"
}

resource "aws_iam_group_policy" "pgo_group_svc_policy" {
    name = "${var.environment}-svc-${random_string.suffix.result}"
    group = aws_iam_group.pgo_group_svc.id
    policy = local.policy_svc
}
