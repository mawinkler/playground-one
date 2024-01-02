# #############################################################################
# Outputs
# #############################################################################
output "ec2_profile" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_profile_db" {
  value = aws_iam_instance_profile.ec2_profile_db.name
}