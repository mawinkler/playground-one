# #############################################################################
# Create S3 bucket
# #############################################################################
resource "random_string" "random_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "playground_awsone" {
  bucket        = "${var.environment}-bucket-${random_string.random_suffix.result}"
  force_destroy = true

  tags = {
    Name          = "${var.environment}-s3-bucket"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "testlab-cs"
  }
}

resource "aws_s3_bucket_ownership_controls" "playground_awsone" {
  bucket = aws_s3_bucket.playground_awsone.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
