# #############################################################################
# Creating a S3 Bucket for Terraform state file upload.
# #############################################################################
# data "aws_caller_identity" "current" {}

# resource "aws_s3_bucket" "bucket_tf_files" {
#   bucket        = "do-not-delete-awsgoat-state-files-${data.aws_caller_identity.current.account_id}"
#   force_destroy = true
#   tags = {
#     Name          = "${var.environment}-s3-bucket"
#     Environment   = "${var.environment}"
#     Product       = "playground-one"
#     Configuration = "goat"
#   }
# }
