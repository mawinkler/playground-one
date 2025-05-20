# #############################################################################
# Deploy Wireguard Server
# #############################################################################
resource "aws_network_interface" "wireguard_eni" {
  subnet_id       = var.public_subnets[0]
  private_ips     = [var.vpn_private_ip]
  security_groups = [aws_security_group.wireguard["public"].id]
}

resource "aws_eip_association" "wireguard" {
  network_interface_id = aws_network_interface.wireguard_eni.id
  # instance_id   = aws_instance.wireguard[0].id
  allocation_id = aws_eip.wireguard.id
}

resource "aws_eip" "wireguard" {
  tags = { Name = "wireguard" }
}

resource "aws_instance" "wireguard" {
  count                       = 1
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t4g.nano"
  user_data                   = local.userdata
  user_data_replace_on_change = true

  # Attach the ENI to the instance
  network_interface {
    network_interface_id = aws_network_interface.wireguard_eni.id
    device_index         = 0 # Primary network interface
  }

  tags = {
    Name          = "${var.environment}-wireguard"
    Environment   = "${var.environment}"
  }
}
