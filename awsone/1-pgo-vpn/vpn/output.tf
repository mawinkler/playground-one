# #############################################################################
# Outputs
# #############################################################################
output "vpn_client_conf_admin" {
  value = local_file.peer_conf["admin"].filename
}

output "vpn_client_conf_user1" {
  value = local_file.peer_conf["user1"].filename
}

output "vpn_client_conf_user2" {
  value = local_file.peer_conf["user2"].filename
}

output "vpn_client_conf_user3" {
  value = local_file.peer_conf["user3"].filename
}

output "vpn_server_ip" {
  value = length(aws_instance.wireguard) > 0 ? aws_instance.wireguard[0].public_ip : null
}

output "vpn_server_pip" {
  value = length(aws_instance.wireguard) > 0 ? aws_instance.wireguard[0].private_ip : null
}

output "vpn_server_id" {
  value = length(aws_instance.wireguard) > 0 ? aws_instance.wireguard[0].id : null
}

output "vpn_up_admin" {
  description = "Command to establish VPN connection"
  value       = length(aws_instance.wireguard) > 0 ? format("wg-quick up %s", local_file.peer_conf["admin"].filename) : null
}
