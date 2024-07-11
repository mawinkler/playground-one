output "secret_key" {
    value = aws_iam_access_key.pgo_access_key.secret
    sensitive = true
}

output "access_key" {
    value = aws_iam_access_key.pgo_access_key.id
}
