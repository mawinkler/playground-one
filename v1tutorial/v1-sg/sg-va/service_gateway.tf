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
  }
}

resource "aws_network_interface" "sg_va" {
  subnet_id       = var.private_subnets[0]
  security_groups = [aws_security_group.sg_va.id]
  description     = "Service Gateway Network Interface"

  tags = {
    Name          = "${var.environment}-sg-va"
    Environment   = "${var.environment}"
  }
}

output "sg_va_pip" {
  value = aws_network_interface.sg_va.private_ip
}

output "sg_va_ami" {
  value = aws_instance.sg_va.ami
}
