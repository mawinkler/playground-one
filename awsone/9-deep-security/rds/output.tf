# #############################################################################
# Outputs
# #############################################################################
output "rds_name" {
  value = module.db.db_instance_name
}

output "rds_address" {
  value = module.db.db_instance_address
}

output "rds_password" {
  value = random_string.rds_password.result
}
