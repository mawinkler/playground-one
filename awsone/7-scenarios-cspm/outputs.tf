# #############################################################################
# Outputs
# #############################################################################
output "s3_bucket" {
  description = "S3 bucket with public read"
  value = module.s3.s3_bucket
}

output "s3_bucket_arn" {
  value = module.s3.s3_bucket_arn
}
