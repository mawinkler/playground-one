# #############################################################################
# Outputs
# #############################################################################
output "postgres_instance_id" {
  description = "Bastion instance id"
  value       = length(aws_instance.postgres) > 0 ? aws_instance.postgres.id : null
}

# output "postgres_public_ip" {
#   description = "Bastion public IP"
#   value       = length(aws_instance.bastion) > 0 ? aws_instance.postgres.public_ip : null
# }

output "postgres_private_ip" {
  description = "Bastion private IP"
  value       = length(aws_instance.postgres) > 0 ? aws_instance.postgres.private_ip : null
}

output "postgres_password" {
  value = random_string.psql_password.result
}

output "ssh_instance_postgres" {
  description = "Command to ssh to instance postgres"
  value       = length(aws_instance.postgres) > 0 ? "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@${aws_instance.postgres.private_ip}" : null
}
