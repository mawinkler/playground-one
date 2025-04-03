# #############################################################################
# Windows Member Servers / Clients
# #############################################################################
# Compute the AMI list: use provided AMIs or fallback to default AMI
locals {
  ami_list = length(var.ami_windows_client) > 0 ? var.ami_windows_client : [
    for i in range(var.windows_client_count) : data.aws_ami.windows.id
  ]

  default_subnet1 = "${var.windows_server_private_ip}/24"
  ip_addresses    = [for i in range(10, 10 + var.windows_client_count) : cidrhost(local.default_subnet1, i)]
}

resource "aws_network_interface" "windows_client_eni" {
  for_each        = { for idx, ip in local.ip_addresses : idx => ip }
  subnet_id       = var.private_subnets[1]
  private_ips     = [each.value]
  security_groups = [var.private_security_group_id]
}

resource "aws_instance" "windows_client" {

  for_each                    = { for idx, ami in local.ami_list : idx => ami }
  ami                         = each.value
  instance_type               = var.windows_instance_type
  iam_instance_profile        = var.ec2_profile
  key_name                    = var.key_name
  get_password_data           = false
  user_data_replace_on_change = true

  network_interface {
    network_interface_id = aws_network_interface.windows_client_eni[each.key].id
    device_index         = 0 # Primary network interface
  }

  user_data = templatefile("${path.module}/userdata_windows_client.tftpl", {
    s3_bucket                = var.s3_bucket
    windows_ad_user_name     = var.windows_username
    windows_ad_hostname      = "Client-${each.key}"
    windows_ad_safe_password = var.windows_ad_safe_password
    windows_ad_domain_name   = var.active_directory ? var.windows_ad_domain_name : ""

    userdata_windows_winrm   = local.userdata_function_windows_winrm
    userdata_windows_ssh     = local.userdata_function_windows_ssh
    userdata_windows_aws     = local.userdata_function_windows_aws
    userdata_windows_join_ad = local.userdata_function_windows_join_ad
  })

  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name          = "${var.environment}-windows-client-${each.key}"
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
