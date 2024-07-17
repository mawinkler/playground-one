# #############################################################################
# Outputs
# #############################################################################
output "secret_key" {
  value     = aws_iam_access_key.attacker_access_key.secret
  sensitive = true
}

output "access_key" {
  value = aws_iam_access_key.attacker_access_key.id
}

output "attacker_arn" {
  value = aws_iam_user.attacker.arn
}
