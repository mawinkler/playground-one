# IAM
output "access_key" {
  value = module.iam.access_key
}

output "secret_key" {
  value = module.iam.secret_key
      sensitive = true
}

output "user_arn" {
  value = module.iam.user_arn
}

output "group_arn" {
  value = module.iam.group_arn
}
