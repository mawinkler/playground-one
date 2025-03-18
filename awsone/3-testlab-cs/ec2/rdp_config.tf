resource "local_file" "apex_one_server_rdp_config" {
  count = var.create_apex_one_server ? 1 : 0

  filename = "../../vpn-rdps/apex-one-server.rdp"
  content  = templatefile("${path.module}/rdp_config.tftpl", {
    hostname = aws_instance.apex_one_server[0].private_ip
    username = "Administrator@${var.environment}.local"
  })
}

resource "local_file" "apex_one_central_rdp_config" {
  count = var.create_apex_one_central ? 1 : 0

  filename = "../../vpn-rdps/apex-one-central.rdp"
  content  = templatefile("${path.module}/rdp_config.tftpl", {
    hostname = aws_instance.apex_one_central[0].private_ip
    username = "Administrator@${var.environment}.local"
  })
}

resource "local_file" "windows_client_rdp_config" {
  count = var.windows_client_count ? 1 : 0

  filename = "../../vpn-rdps/windows-client-${count.index}.rdp"
  content  = templatefile("${path.module}/rdp_config.tftpl", {
    hostname = aws_instance.windows_client[count.index].private_ip
    username = "Administrator@${var.environment}.local"
  })
}
