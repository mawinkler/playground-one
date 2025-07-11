# #############################################################################
# Exchange Transport Server
# #############################################################################
resource "aws_network_interface" "transport_eni" {
  subnet_id       = var.private_subnets[0]
  private_ips     = [var.transport_private_ip]
  security_groups = [var.private_security_group_id]
}

resource "aws_instance" "transport" {

  count = var.create_exchange ? 1 : 0

  ami                         = var.ami_transport != "" ? var.ami_transport : data.aws_ami.windows.id
  instance_type               = var.transport_instance_type
  iam_instance_profile        = var.ec2_profile
  key_name                    = var.key_name
  user_data                   = local.userdata_transport
  get_password_data           = false
  user_data_replace_on_change = true

  network_interface {
    network_interface_id = aws_network_interface.transport_eni.id
    device_index         = 0 # Primary network interface
  }

  root_block_device {
    volume_size           = var.transport_root_volume_size
    volume_type           = var.transport_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name          = "${var.environment}-transport"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "testlab-cs"
    Type          = "${var.environment}-windows-server"
  }

  connection {
    host     = coalesce(self.public_ip, self.private_ip)
    type     = "winrm"
    port     = 5986
    user     = var.windows_username
    password = var.windows_ad_safe_password
    https    = true
    insecure = true
    timeout  = "13m"
  }
}

# # AWS Systems Manager
# resource "aws_ssm_association" "windows_server_agent" {
#   count = var.agent_deploy ? var.agent_variant == "TMServerAgent" ? var.windows_count : 0 : 0

#   name = aws_ssm_document.server-agent-windows.name

#   targets {
#     key    = "InstanceIds"
#     values = [aws_instance.windows-server[count.index].id]
#   }
# }

# resource "aws_ssm_association" "windows_sensor_agent" {
#   count = var.agent_deploy ? var.agent_variant == "TMSensorAgent" ? var.windows_count : 0 : 0

#   name = aws_ssm_document.sensor-agent-windows.name

#   targets {
#     key    = "InstanceIds"
#     values = [aws_instance.windows-server[count.index].id]
#   }
# }

# # Traffic Mirror
# resource "aws_ec2_traffic_mirror_session" "vns_traffic_mirror_session_win" {
#   count = var.virtual_network_sensor && var.create_windows ? 1 : 0

#   description              = "VNS Traffic mirror session - Windows Server"
#   session_number           = 1
#   network_interface_id     = aws_instance.windows-server[0].primary_network_interface_id
#   traffic_mirror_filter_id = var.vns_va_traffic_mirror_filter_id
#   traffic_mirror_target_id = var.vns_va_traffic_mirror_target_id
# }

# resource "aws_ec2_traffic_mirror_session" "ddi_traffic_mirror_session_win" {
#   count = var.deep_discovery_inspector && var.create_windows ? 1 : 0

#   description              = "DDI Traffic mirror session - Windows Server"
#   session_number           = 1
#   network_interface_id     = aws_instance.windows-server[0].primary_network_interface_id
#   traffic_mirror_filter_id = var.ddi_va_traffic_mirror_filter_id
#   traffic_mirror_target_id = var.ddi_va_traffic_mirror_target_id
# }
