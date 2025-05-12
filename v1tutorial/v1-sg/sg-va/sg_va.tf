# #############################################################################
# Linux Instance for Service Gateway
# #############################################################################
resource "aws_instance" "sg_va" {
  ami           = data.aws_ami.sg_va.id
  instance_type = "c5.2xlarge"
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
  subnet_id       = var.private_subnets[0]
  security_groups = [aws_security_group.sg_va.id]
  description     = "Service Gateway Network Interface"

  tags = {
    Name          = "${var.environment}-sg-va"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}
