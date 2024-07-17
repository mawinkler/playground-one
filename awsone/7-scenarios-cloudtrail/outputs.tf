# #############################################################################
# Outputs
# #############################################################################
# IAM
output "access_key" {
  value = module.credentials.access_key
}

output "secret_key" {
  value     = module.credentials.secret_key
  sensitive = true
}

output "attacker_arn" {
  value = module.credentials.attacker_arn
}

# S3
output "s3_bucket" {
  value = module.s3.s3_bucket
}

output "attack" {
  value = data.external.attack.result
}
