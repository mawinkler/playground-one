# #############################################################################
# Create IAM roles, admin and user
# #############################################################################
resource "aws_iam_policy" "additional" {
  name = "pgo-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
