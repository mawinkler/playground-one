# #############################################################################
# RDP Configs
# #############################################################################
resource "local_file" "pgo_dc_rdp_config" {
  filename = "../../vpn-rdps/pgo-dc.rdp"
  content = templatefile("${path.module}/rdp_config.tftpl", {
    hostname = aws_instance.windows-server-dc.private_ip
    username = "Administrator@${var.environment}.local"
  })
}

resource "local_file" "pgo-ca_rdp_config" {
  filename = "../../vpn-rdps/pgo-ca.rdp"
  content = templatefile("${path.module}/rdp_config.tftpl", {
    hostname = aws_instance.windows-server-ca.private_ip
    username = "Administrator@${var.environment}.local"
  })
}
