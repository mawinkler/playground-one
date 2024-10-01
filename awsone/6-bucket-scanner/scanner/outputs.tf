# #############################################################################
# Outputs
# #############################################################################
output "aws_s3_bucket_name" {
  description = "S3 Scanning Bucket name"
  value       = aws_s3_bucket.playground_awsone.bucket
}

output "aws_lambda_function_name" {
  description = "Lambda Function name"
  value       = aws_lambda_function.scanner_handler.id
}

output "aws_lambda_layer_arn" {
  description = "Lambda Layer ARN"
  value       = aws_lambda_layer_version.lambda_layer.arn
}
