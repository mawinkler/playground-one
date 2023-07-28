# #############################################################################
# Outputs
# #############################################################################
output "key_name" {
  value = "${aws_key_pair.key_pair.key_name}"
}

output "public_key" {
  value = "${trimspace(tls_private_key.key_pair.public_key_openssh)}"
}

output "private_key_path" {
  value = "../${aws_key_pair.key_pair.key_name}.pem"
}
