# #############################################################################
# IAM
# #############################################################################
resource "aws_iam_role" "pgo_scanner_lambda_role" {
  name               = "${var.environment}-scanner-lambda-role-${random_string.random_suffix.result}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "pgo_scanner_lambda_rolePolicy" {
  role       = aws_iam_role.pgo_scanner_lambda_role.name
  policy_arn = aws_iam_policy.pgo_scanner_lambda_policy.arn
}

resource "aws_iam_policy" "pgo_scanner_lambda_policy" {
  name        = "${var.environment}-pgo-scanner-lambda-policy-${random_string.random_suffix.result}"
  path        = "/"
  description = "IAM policy for PGO scanner lambda functions"
  policy      = local.pgo_scanner_lambda_policy
}
