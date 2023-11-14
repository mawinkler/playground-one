# #############################################################################
# Upload files to S3 bucket
# #############################################################################
resource "aws_s3_object" "object" {
  for_each = fileset("files/", "*")
  bucket   = aws_s3_bucket.playground_awsone.id
  key      = format("download/%s", each.value)
  source   = "files/${each.value}"

  tags = {
    Name          = "${var.environment}-s3-object"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "dsm"
  }
}
