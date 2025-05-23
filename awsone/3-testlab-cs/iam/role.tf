# #############################################################################
# EC2 Instance Role
# #############################################################################
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# Create a policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.environment}-ec2-policy-${random_string.suffix.result}"
  path        = "/"
  description = "Policy to provide permission to EC2"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # PGO S3 Bucket
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
      # Systems Manager
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:DescribeAssociation",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:DescribeDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutInventory",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    Name          = "${var.environment}-ec2-policy"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "testlab-cs"
  }
}

# Create a role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
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
    Configuration = "testlab-cs"
  }
}

# Attach role to policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment
resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name       = "${var.environment}-ec2-attachment-${random_string.suffix.result}"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# Attach role to an instance profile
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile-${random_string.suffix.result}"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name          = "${var.environment}-ec2-profile"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "testlab-cs"
  }
}

# #############################################################################
# AWS Systems Manager with private subnets
# #############################################################################
# resource "aws_iam_policy" "ssm_policy" {
#   name        = "${var.environment}-ssm-policy-${random_string.suffix.result}"
#   path        = "/"
#   description = "Session Manager Permissions"
#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "ssmmessages:CreateControlChannel",
#           "ssmmessages:CreateDataChannel",
#           "ssmmessages:OpenControlChannel",
#           "ssmmessages:OpenDataChannel"
#         ],
#         "Resource" : "*"
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "s3:GetEncryptionConfiguration"
#         ],
#         "Resource" : "*"
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "kms:Decrypt"
#         ],
#         "Resource" : "${var.ssm_key}"
#       }
#     ]
#   })

#   tags = {
#     Name          = "${var.environment}-ec2-policy"
#     Environment   = "${var.environment}"
#     Product       = "playground-one"
#     Configuration = "ec2"
#   }
# }

# resource "aws_iam_role" "ssm_role" {
#   name = "${var.environment}-ssm-role-${random_string.suffix.result}"
#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })

#   tags = {
#     Name          = "${var.environment}-ssm-role"
#     Environment   = "${var.environment}"
#     Product       = "playground-one"
#     Configuration = "ec2"
#   }
# }


# resource "aws_iam_policy_attachment" "ssm_policy_role" {
#   name       = "${var.environment}-ssm-attachment-${random_string.suffix.result}"
#   roles      = [aws_iam_role.ssm_role.name]
#   policy_arn = aws_iam_policy.ssm_policy.arn
# }
