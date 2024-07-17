# #############################################################################
# Upload files to S3 bucket
# #############################################################################
resource "aws_s3_object" "object" {
  for_each = fileset("uploads", "*")
  bucket   = aws_s3_bucket.playground_awsone.id
  key      = format("uploads/%s", each.value)
  source   = "uploads/${each.value}"

  tags = {
    Name          = "${var.environment}-s3-object"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }
}
