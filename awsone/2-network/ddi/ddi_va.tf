# #############################################################################
# Linux Instance for Service Gateway
# #############################################################################
resource "aws_instance" "ddi_va" {
  ami           = data.aws_ami.ddi_va.id
  instance_type = var.instance_type
  key_name      = var.key_name

  root_block_device {
    delete_on_termination = true
  }

  network_interface {
    network_interface_id = aws_network_interface.ddi_va_ni_data_public.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.ddi_va_ni_data_private.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.ddi_va_ni_management.id
    device_index         = 2
  }

  tags = {
    Name          = "${var.environment}-ddi-va"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }

  user_data = local.userdata_ddi_va
}

resource "aws_network_interface" "ddi_va_ni_data_public" {
  subnet_id       = var.public_subnets[0]
  security_groups = [aws_security_group.sg["data_port"].id]
  description     = "Deep Discovery Inspector Data Port"

  tags = {
    Name          = "${var.environment}-ddi-ni-data"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

resource "aws_network_interface" "ddi_va_ni_data_private" {
  subnet_id       = var.private_subnets[0]
  security_groups = [aws_security_group.sg["data_port"].id]
  description     = "Deep Discovery Inspector Data Port"

  tags = {
    Name          = "${var.environment}-ddi-ni-data"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

resource "aws_network_interface" "ddi_va_ni_management" {
  subnet_id       = var.public_subnets[0]
  security_groups = [aws_security_group.sg["management_port"].id]
  description     = "Deep Discovery Inspector Management Port"

  tags = {
    Name          = "${var.environment}-ddi-ni-management"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

resource "aws_eip" "ddi_va_public_ip" {
  network_interface = aws_network_interface.ddi_va_ni_management.id
  domain            = "vpc"
}
