# #############################################################################
# Outputs
# #############################################################################
output "rds_identifier" {
  value = module.db.db_instance_identifier
}

output "rds_address" {
  value = module.db.db_instance_address
}

output "rds_password" {
  value = random_string.rds_password.result
}
