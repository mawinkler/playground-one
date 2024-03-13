# #############################################################################
# EC2 Instance Role
# #############################################################################
# Create a policy with RDS Read access
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "ec2_policy_db" {
  name        = "${var.environment}-ec2-policy-db-${random_string.suffix.result}"
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
          "arn:aws:s3:::${var.s3_bucket}",
          "arn:aws:s3:::${var.s3_bucket}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:Describe*",
          "rds:ListTagsForResource",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "devops-guru:GetResourceCollection"
        ],
        "Resource" : "*"
      },
      {
        "Action" : [
          "devops-guru:SearchInsights",
          "devops-guru:ListAnomaliesForInsight"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Condition" : {
          "ForAllValues:StringEquals" : {
            "devops-guru:ServiceNames" : [
              "RDS"
            ]
          },
          "Null" : {
            "devops-guru:ServiceNames" : "false"
          }
        }
      }
    ]
  })

  tags = {
    Name          = "${var.environment}-ec2-policy-db"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }
}

# Create a role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "ec2_role_db" {
  name = "${var.environment}-ec2-role-db-${random_string.suffix.result}"
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
    Name          = "${var.environment}-ec2-role-db"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }
}

# Attach role to policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment
resource "aws_iam_policy_attachment" "ec2_policy_role_db" {
  name       = "${var.environment}-ec2-attachment-db-${random_string.suffix.result}"
  roles      = [aws_iam_role.ec2_role_db.name]
  policy_arn = aws_iam_policy.ec2_policy_db.arn
}

# Attach role to an instance profile
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "ec2_profile_db" {
  name = "${var.environment}-ec2-profile-db-${random_string.suffix.result}"
  role = aws_iam_role.ec2_role_db.name

  tags = {
    Name          = "${var.environment}-ec2-profile-db"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }
}
