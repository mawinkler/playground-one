# #############################################################################
# Outputs
# #############################################################################
output "vpn_client_conf_admin" {
  value = module.vpn.vpn_client_conf_admin
}

output "vpn_client_conf_user1" {
  value = module.vpn.vpn_client_conf_user1
}

output "vpn_client_conf_user2" {
  value = module.vpn.vpn_client_conf_user2
}

output "vpn_client_conf_user3" {
  value = module.vpn.vpn_client_conf_user3
}

output "vpn_server_ip" {
  value = module.vpn.vpn_server_ip
}

output "vpn_server_id" {
  value = module.vpn.vpn_server_id
}

output "vpn_up_admin" {
  value = module.vpn.vpn_up_admin
}
