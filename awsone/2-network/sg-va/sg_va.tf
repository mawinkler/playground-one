# #############################################################################
# Linux Instance for Service Gateway
# #############################################################################
resource "aws_instance" "sg_va" {
  ami           = var.ami_service_gateway != "" ? var.ami_service_gateway : data.aws_ami.sg_va.id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.sg_va.id
    device_index         = 0
  }

  root_block_device {
    delete_on_termination = true
  }

  tags = {
    Name          = "${var.environment}-sg-va"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }

  user_data = local.userdata_sg_va
}

resource "aws_network_interface" "sg_va" {
  # subnet_id       = var.vpn_gateway ? var.private_subnets[0] : var.public_subnets[0]
  # security_groups = var.vpn_gateway ? [var.private_security_group_id] : [var.public_security_group_id]
  subnet_id       = var.private_subnets[0]
  security_groups = [var.private_security_group_id]
  private_ips     = [var.pgo_sg_private_ip]

  tags = {
    Name          = "${var.environment}-pgo-ca-ni"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}
