# #############################################################################
# Linux Instance for Service Gateway
# #############################################################################
resource "aws_instance" "ddi_va" {
  ami           = var.ami_deep_discovery_inspector != "" ? var.ami_deep_discovery_inspector : data.aws_ami.ddi_va.id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.ddi_va_ni_data_private.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.ddi_va_ni_management.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.ddi_va_ni_data_public.id
    device_index         = 2
  }

  root_block_device {
    delete_on_termination = true
  }

  tags = {
    Name          = "${var.environment}-ddi-va"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }

  user_data = local.userdata_ddi_va
}

resource "aws_network_interface" "ddi_va_ni_management" {
  # subnet_id       = var.vpn_gateway ? var.private_subnets[var.pgo_ddi_subnet_no] : var.public_subnets[var.pgo_ddi_subnet_no]
  subnet_id       = var.private_subnets[var.pgo_ddi_subnet_no]
  security_groups = [aws_security_group.sg["management_port"].id]
  description     = "Deep Discovery Inspector Management Port"
  private_ips     = [var.pgo_ddi_private_ip]

  tags = {
    Name          = "${var.environment}-ddi-ni-management"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

resource "aws_network_interface" "ddi_va_ni_data_private" {
  subnet_id       = var.private_subnets[var.pgo_ddi_subnet_no]
  security_groups = [aws_security_group.sg["data_port"].id]

  tags = {
    Name          = "${var.environment}-ddi-ni-data-private"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

resource "aws_network_interface" "ddi_va_ni_data_public" {
  subnet_id       = var.public_subnets[var.pgo_ddi_subnet_no]
  security_groups = [aws_security_group.sg["data_port"].id]

  tags = {
    Name          = "${var.environment}-ddi-ni-data-public"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

# Attach each ENI to the EC2 instance
# resource "aws_network_interface_attachment" "eni_attach_management" {
#   instance_id          = aws_instance.ddi_va.id
#   network_interface_id = aws_network_interface.ddi_va_ni_management.id
#   device_index         = 0
# }

# resource "aws_network_interface_attachment" "eni_attach_private" {
#   instance_id          = aws_instance.ddi_va.id
#   network_interface_id = aws_network_interface.ddi_va_ni_data_private.id
#   device_index         = 1
# }

# # Attach each ENI to the EC2 instance
# resource "aws_network_interface_attachment" "eni_attach_public" {
#   instance_id          = aws_instance.ddi_va.id
#   network_interface_id = aws_network_interface.ddi_va_ni_data_public.id
#   device_index         = 2
# }


# resource "aws_eip" "ddi_va_public_ip" {
#   network_interface = aws_network_interface.ddi_va_ni_management.id
#   domain            = "vpc"
# }

# DOES NOT WORK ACCROSS MULTIPE AZ
# # Create ENIs for each subnet (3 private + 3 public)
# resource "aws_network_interface" "eni" {
#   count           = 6
#   subnet_id       = count.index < 3 ? var.private_subnets[count.index] : var.public_subnets[count.index - 3]
#   # security_groups = [aws_security_group.allow_internal.id]
#   security_groups = [aws_security_group.sg["data_port"].id]

#   tags = {
#     Name = "${var.environment}-ddi-ni-data-${count.index}"
#     Environment   = "${var.environment}"
#     Product       = "playground-one"
#     Configuration = "nw"  }
# }

# # Attach each ENI to the EC2 instance
# resource "aws_network_interface_attachment" "eni_attach" {
#   count                = 6
#   instance_id          = aws_instance.ddi_va.id
#   network_interface_id = aws_network_interface.eni[count.index].id
#   device_index         = count.index + 1  # eth1, eth2, eth3, ...
# }
