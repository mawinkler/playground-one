# #############################################################################
# Outputs
# #############################################################################
output "s3_bucket" {
  value = aws_s3_bucket.playground_awsone_scenario.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.playground_awsone_scenario.arn
}
