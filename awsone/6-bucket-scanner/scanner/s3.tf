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
