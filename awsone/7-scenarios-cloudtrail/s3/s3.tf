# #############################################################################
# Create S3 bucket
# #############################################################################
resource "random_string" "random_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "playground_awsone" {
  bucket        = "${var.environment}-scenarios-${random_string.random_suffix.result}"
  force_destroy = true

  tags = {
    Name          = "${var.environment}-scenarios-${random_string.random_suffix.result}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "scenarios-cloudtrail"
  }
}

resource "aws_s3_bucket_ownership_controls" "playground_awsone" {
  bucket = aws_s3_bucket.playground_awsone.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
