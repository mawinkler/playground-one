# #############################################################################
# Outputs
# #############################################################################
output "ec2_profile" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_profile_db" {
  value = aws_iam_instance_profile.ec2_profile_db.name
}

output "pgo_dbadmin_access_key" {
  value = var.create_attackpath ? aws_iam_access_key.pgo_dbadmin_access_key[0].id : null
}

output "pgo_dbadmin_secret_access_key" {
  value     = var.create_attackpath ? aws_iam_access_key.pgo_dbadmin_access_key[0].secret : null
  sensitive = true
}
