# #############################################################################
# Windows Instance
#   Vision One Server & Workload Protection
#   Atomic Launcher
# #############################################################################
resource "random_password" "windows_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_instance" "windows-server" {

  count = var.create_windows ? var.windows_count : 0

  ami                    = data.aws_ami.windows.id
  instance_type          = var.windows_instance_type
  subnet_id              = var.public_subnets[1]
  vpc_security_group_ids = [var.public_security_group_id]
  iam_instance_profile   = var.ec2_profile
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-windows-server-${count.index}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
    Type          = "${var.environment}-windows-server"
  }

  user_data = local.userdata_windows

  connection {
    host     = coalesce(self.public_ip, self.private_ip)
    type     = "winrm"
    port     = 5986
    user     = var.windows_username
    password = random_password.windows_password.result
    https    = true
    insecure = true
    timeout  = "13m"
  }
}

# AWS Systems Manager
resource "aws_ssm_association" "windows_server_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMServerAgent" ? var.linux_db_count : 0 : 0

  name = aws_ssm_document.server-agent-windows.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.windows-server[count.index].id]
  }
}

resource "aws_ssm_association" "windows_sensor_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMSensorAgent" ? var.linux_db_count : 0 : 0

  name = aws_ssm_document.sensor-agent-windows.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.windows-server[count.index].id]
  }
}

# Traffic Mirror
resource "aws_ec2_traffic_mirror_session" "vns_traffic_mirror_session_win" {
  count = var.virtual_network_sensor && var.create_windows ? 1 : 0

  description              = "VNS Traffic mirror session - Windows Server"
  session_number           = 1
  network_interface_id     = aws_instance.windows-server[0].primary_network_interface_id
  traffic_mirror_filter_id = var.vns_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.vns_va_traffic_mirror_target_id
}

resource "aws_ec2_traffic_mirror_session" "ddi_traffic_mirror_session_win" {
  count = var.deep_discovery_inspector && var.create_windows ? 1 : 0

  description              = "DDI Traffic mirror session - Windows Server"
  session_number           = 1
  network_interface_id     = aws_instance.windows-server[0].primary_network_interface_id
  traffic_mirror_filter_id = var.ddi_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.ddi_va_traffic_mirror_target_id
}
