# #############################################################################
# Create S3 bucket
# #############################################################################
resource "random_string" "random_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "playground_awsone_scenario" {
  bucket        = "playground-awsone-scenario3-${random_string.random_suffix.result}"
  force_destroy = true

  tags = {
    Name          = "${var.environment}-s3-bucket"
    Environment   = "${var.environment}"
    Product       = "playground-two"
    Configuration = "ec2"
  }
}

resource "aws_kms_key" "playground_awsone_scenario_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "playground_awsone_scenario_encryption" {
  bucket = aws_s3_bucket.playground_awsone_scenario.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.playground_awsone_scenario_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# # Public Access Tests
# resource "aws_s3_bucket_public_access_block" "playground_awsone_scenario" {
#   bucket = aws_s3_bucket.playground_awsone_scenario.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

# resource "aws_s3_bucket_policy" "allow_public_access" {
#   bucket = aws_s3_bucket.playground_awsone_scenario.id
#   policy = data.aws_iam_policy_document.allow_public_access.json
# }

# data "aws_iam_policy_document" "allow_public_access" {
#   statement {
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }

#     actions = [
#       "s3:GetObject"
#     ]

#     resources = [
#       aws_s3_bucket.playground_awsone_scenario.arn,
#       "${aws_s3_bucket.playground_awsone_scenario.arn}/*",
#     ]
#   }
# }

# resource "aws_s3_bucket_acl" "acl" {
#   depends_on = [aws_s3_bucket_ownership_controls.ownership]
#   bucket     = aws_s3_bucket.playground_awsone_scenario.id
#   acl        = "public-read"
# }

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.playground_awsone_scenario.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
