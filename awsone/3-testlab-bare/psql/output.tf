# #############################################################################
# Outputs
# #############################################################################
output "postgres_instance_id" {
  description = "PostgreSQL instance id"
  value       = length(aws_instance.postgres) > 0 ? aws_instance.postgres.id : null
}

output "postgres_private_ip" {
  description = "PostgreSQL private IP"
  value       = length(aws_instance.postgres) > 0 ? aws_instance.postgres.private_ip : null
}

output "postgres_password" {
  value = random_string.psql_password.result
}

output "ssh_instance_postgres" {
  description = "Command to ssh to instance postgres"
  value       = length(aws_instance.postgres) > 0 ? "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@${aws_instance.postgres.private_ip}" : null
}
