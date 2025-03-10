# Create EC2 Instance
resource "aws_instance" "windows-server-ca" {
  ami                    = data.aws_ami.windows-server.id
  instance_type          = var.windows_instance_type
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  source_dest_check      = false
  key_name               = var.key_name
  user_data              = local.userdata_ca

  # root disk
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
  network_interface_id     = aws_instance.windows-server-ca.primary_network_interface_id #"eni-01b3fee96390b91bb" # aws_instance.test.primary_network_interface_id
  traffic_mirror_filter_id = var.vns_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.vns_va_traffic_mirror_target_id
}
