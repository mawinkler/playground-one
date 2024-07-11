# IAM
output "access_key" {
  value = module.iam.access_key
}

output "secret_key" {
  value = module.iam.secret_key
      sensitive = true
}
