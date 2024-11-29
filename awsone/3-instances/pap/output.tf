# #############################################################################
# Outputs
# #############################################################################
# Instance
output "instance_id_linux_pap" {
  value = aws_instance.linux-pap.id
}

output "linux_ip_pap" {
  value = aws_instance.linux-pap.public_ip
}

output "linux_ssh_pap" {
  description = "Command to ssh to instance linux-pap"
  value       = "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@${aws_instance.linux-pap.public_ip}"
}

# RDS
output "rds_identifier" {
  value = module.db.db_instance_identifier
}

output "rds_arn" {
  value = module.db.db_instance_arn
}

output "rds_address" {
  value = module.db.db_instance_address
}

output "rds_password" {
  value = random_string.rds_password.result
}

output "pgo_dbadmin_access_key" {
  value = aws_iam_access_key.pgo_dbadmin_access_key.id
}

output "pgo_dbadmin_secret_access_key" {
  value     = aws_iam_access_key.pgo_dbadmin_access_key.secret
  sensitive = true
}
