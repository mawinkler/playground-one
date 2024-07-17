# #############################################################################
# EC2 Instance Role
# #############################################################################
# Create a policy for RDS
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.environment}-ec2-policy-${random_string.suffix.result}"
  path        = "/"
  description = "Policy to provide permission to EC2"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:List*"
        ],
        "Resource" : [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      },
    ]
  })

  tags = {
    Name          = "${var.environment}-ec2-policy"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "scenarios-cloudtrail"
  }
}

# Create a role
resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2-role-${random_string.suffix.result}"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name          = "${var.environment}-ec2-role"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "scenarios-cloudtrail"
  }
}

# Attach role to policy
resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name       = "${var.environment}-ec2-attachment-${random_string.suffix.result}"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# Attach role to an instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile-${random_string.suffix.result}"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name          = "${var.environment}-ec2-profile"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "scenarios-cloudtrail"
  }
}
