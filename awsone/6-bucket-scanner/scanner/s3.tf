# #############################################################################
# S3 bucket
# #############################################################################
resource "aws_s3_bucket" "playground_awsone" {
  bucket        = "${var.environment}-scanning-bucket-${random_string.random_suffix.result}"
  force_destroy = true

  tags = {
    Name          = "${var.environment}-s3-bucket"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }
}

resource "aws_s3_bucket_ownership_controls" "playground_awsone" {
  bucket = aws_s3_bucket.playground_awsone.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_accelerate_configuration" "playground_awsone" {
  bucket = aws_s3_bucket.playground_awsone.id
  status = "Enabled"
}

resource "aws_s3_bucket_versioning" "playground_awsone" {
  bucket = aws_s3_bucket.playground_awsone.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "playground_awsone" {
  bucket = aws_s3_bucket.playground_awsone.id
  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 5
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "playground_awsone" {
  bucket = aws_s3_bucket.playground_awsone.id

  rule {
    id = "transition-malicious-files"

    filter {
      tag {
        key   = "fss-scan-result"
        value = "malicious"
      }
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.playground_awsone.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.scanner_handler.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scanner_handler.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.playground_awsone.arn
}
