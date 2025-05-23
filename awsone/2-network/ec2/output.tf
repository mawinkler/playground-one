# #############################################################################
# Outputs
# #############################################################################
output "key_name" {
  value = aws_key_pair.key_pair.key_name
}

output "public_key" {
  value = trimspace(tls_private_key.key_pair.public_key_openssh)
}

output "private_key" {
  value = trimspace(tls_private_key.key_pair.private_key_openssh)
}

output "private_key_path" {
  value = local_file.ssh_key.filename
}

output "public_security_group_id" {
  value = aws_security_group.sg["public"].id
}

output "private_security_group_id" {
  value = aws_security_group.sg["private"].id
}

output "ssm_document_sensor_agent_linux" {
  value = aws_ssm_document.sensor-agent-linux
}

output "ssm_document_server_agent_linux" {
  value = aws_ssm_document.server-agent-linux
}

output "ssm_document_sensor_agent_windows" {
  value = aws_ssm_document.sensor-agent-windows
}

output "ssm_document_server_agent_windows" {
  value = aws_ssm_document.server-agent-windows
}

# output "ssm_key" {
#   value = aws_kms_alias.ssm_key_alias.arn
# }
