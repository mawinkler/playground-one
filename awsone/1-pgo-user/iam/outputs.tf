output "secret_key" {
  value     = aws_iam_access_key.pgo_access_key.secret
  sensitive = true
}

output "access_key" {
  value = aws_iam_access_key.pgo_access_key.id
}

output "user_arn" {
  value = aws_iam_user.pgo_user.arn
}

output "group_arn" {
  value = aws_iam_group.pgo_group.arn
}
