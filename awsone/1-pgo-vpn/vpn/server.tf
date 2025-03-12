# #############################################################################
# Deploy Wireguard Server
# #############################################################################
resource "aws_eip_association" "wireguard" {
  instance_id   = aws_instance.wireguard[0].id
  allocation_id = aws_eip.wireguard.id
}

resource "aws_eip" "wireguard" {
  tags = { Name = "wireguard" }
}

resource "aws_instance" "wireguard" {
  count                       = 1
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t4g.nano"
  subnet_id                   = data.aws_subnets.public.ids[0]
  vpc_security_group_ids      = [aws_security_group.wireguard.id]
  user_data                   = local.userdata
  user_data_replace_on_change = true

  tags = {
    Name          = "${var.environment}-wireguard"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}
