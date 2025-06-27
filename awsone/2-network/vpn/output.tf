# #############################################################################
# Outputs
# #############################################################################
output "vpn_client_conf_admin" {
  value = join("/", slice(split("/", local_file.peer_conf["admin_0"].filename), 2, 4))
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

output "vpn_server_security_group_id" {
  value = aws_security_group.wireguard["public"].id
}

output "vpn_up_admin" {
  description = "Command to establish VPN connection"
  value       = length(aws_instance.wireguard) > 0 ? format("wg-quick up $ONEPATH/%s", join("/", slice(split("/", local_file.peer_conf["admin_0"].filename), 2, 4))) : null
}

output "vpn_conf_admin" {
  description = "Command to retrieve VPN configurations"
  value       = length(aws_instance.wireguard) > 0 ? "for cnf in $ONEPATH/vpn-peers/*.conf; do echo; echo '+++'; echo $cnf; echo '==='; cat $cnf; echo '---'; done" : null
}
