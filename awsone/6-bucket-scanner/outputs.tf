# #############################################################################
# Outputs
# #############################################################################
output "aws_s3_bucket_name" {
  description = "S3 Scanning Bucket name"
  value       = module.scanner.aws_s3_bucket_name
}

output "aws_lambda_function_name" {
  description = "Lambda Function name"
  value       = module.scanner.aws_lambda_function_name
}
