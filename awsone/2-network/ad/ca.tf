# #############################################################################
# Certification Authority
# #############################################################################
resource "aws_network_interface" "windows-server-ca" {
  subnet_id       = var.vpn_gateway ? var.private_subnets[0] : var.public_subnets[0]
  security_groups = var.vpn_gateway ? [var.private_security_group_id] : [var.public_security_group_id]
  private_ips     = [var.pgo_ca_private_ip]

  tags = {
    Name          = "${var.environment}-pgo-ca-ni"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

resource "aws_instance" "windows-server-ca" {
  ami                  = var.ami_active_directory_ca != "" ? var.ami_active_directory_ca : data.aws_ami.windows-server.id
  instance_type        = var.windows_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name             = var.key_name
  user_data            = local.userdata_ca
  get_password_data    = false

  network_interface {
    network_interface_id = aws_network_interface.windows-server-ca.id
    device_index         = 0
  }

  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name          = "${var.environment}-pgo-ca"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
    Type          = "${var.environment}-windows-server"
  }
}

resource "aws_ec2_traffic_mirror_session" "vns_traffic_mirror_session_ca" {
  count = var.virtual_network_sensor ? 1 : 0

  description              = "VNS Traffic mirror session - Windows Server CA"
  session_number           = 1
  network_interface_id     = aws_instance.windows-server-ca.primary_network_interface_id
  traffic_mirror_filter_id = var.vns_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.vns_va_traffic_mirror_target_id
}
