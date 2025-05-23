# #############################################################################
# RDP Configs
# #############################################################################
resource "local_file" "windows_client_rdp_config" {
  count = var.windows_client_count

  filename = "../../vpn-rdps/windows-client-${count.index}.rdp"
  content = templatefile("${path.module}/rdp_config.tftpl", {
    hostname = aws_instance.windows_client[count.index].private_ip
    username = "Administrator@${var.environment}.local"
  })
}
