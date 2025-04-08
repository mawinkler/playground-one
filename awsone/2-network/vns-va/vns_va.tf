# #############################################################################
# Linux Instance for Virtual Network Sensor
# #############################################################################
resource "aws_instance" "vns_va" {
  ami           = data.aws_ami.vns_va.id
  instance_type = var.instance_type

  user_data = var.vns_token

  network_interface {
    network_interface_id = aws_network_interface.vns_va_ni_data_private.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.vns_va_ni_management.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.vns_va_ni_data_public.id
    device_index         = 2
  }

  tags = {
    Name          = "${var.environment}-vns-va"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

resource "aws_network_interface" "vns_va_ni_data_private" {
  subnet_id       = var.private_subnets[var.pgo_vns_subnet_no]
  security_groups = [aws_security_group.sg_va["data_port"].id]
  description     = "Virtual Network Sensor Data Port"

  tags = {
    Name          = "${var.environment}-vns-ni-data"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

resource "aws_network_interface" "vns_va_ni_data_public" {
  subnet_id       = var.public_subnets[var.pgo_vns_subnet_no]
  security_groups = [aws_security_group.sg_va["data_port"].id]
  description     = "Virtual Network Sensor Data Port"

  tags = {
    Name          = "${var.environment}-vns-ni-data"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

resource "aws_network_interface" "vns_va_ni_management" {
  subnet_id       = var.private_subnets[var.pgo_vns_subnet_no]
  security_groups = [aws_security_group.sg_va["management_port"].id]
  description     = "Virtual Network Sensor Management Port"
  private_ips     = [var.pgo_vns_private_ip]

  tags = {
    Name          = "${var.environment}-vns-ni-management"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}
