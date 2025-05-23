# #############################################################################
# Windows Instances
# #############################################################################
resource "aws_instance" "windows-server" {

  count = var.windows_count

  ami                    = data.aws_ami.windows.id
  instance_type          = var.windows_instance_type
  subnet_id              = var.vpn_gateway ? var.private_subnets[1] : var.public_subnets[0]
  vpc_security_group_ids = var.vpn_gateway ? [var.private_security_group_id] : [var.public_security_group_id]
  iam_instance_profile   = var.ec2_profile
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-windows-server-${count.index}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-windows-server"
  }

  user_data = templatefile("${path.module}/../../0-templates/userdata_windows.tftpl", {
    s3_bucket                = var.s3_bucket
    windows_ad_user_name     = var.windows_username
    windows_ad_hostname      = "Member-${count.index}"
    windows_ad_safe_password = var.windows_ad_safe_password
    windows_ad_domain_name   = var.active_directory ? var.windows_ad_domain_name : ""
    tm_agent                 = var.agent_variant

    userdata_windows_winrm   = local.userdata_function_windows_winrm
    userdata_windows_ssh     = local.userdata_function_windows_ssh
    userdata_windows_aws     = local.userdata_function_windows_aws
    userdata_windows_join_ad = local.userdata_function_windows_join_ad
  })

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

# AWS Systems Manager
resource "aws_ssm_association" "windows_server_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMServerAgent" ? var.windows_count : 0 : 0

  name = var.ssm_document_server_agent_windows

  targets {
    key    = "InstanceIds"
    values = [aws_instance.windows-server[count.index].id]
  }

  tags = {
    Name          = "${var.environment}-windows-server-${count.index}-ssm-association"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-windows-server"
  }
}

resource "aws_ssm_association" "windows_sensor_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMSensorAgent" ? var.windows_count : 0 : 0

  name = var.ssm_document_sensor_agent_windows

  targets {
    key    = "InstanceIds"
    values = [aws_instance.windows-server[count.index].id]
  }

  tags = {
    Name          = "${var.environment}-windows-server-${count.index}-ssm-association"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-windows-server"
  }
}

# Traffic Mirror
resource "aws_ec2_traffic_mirror_session" "vns_traffic_mirror_session_windows" {
  count = var.virtual_network_sensor ? length(aws_instance.windows-server) : 0

  description              = "VNS Traffic mirror session - Windows Server"
  session_number           = 1  # We're attaching only one mirror session to the eni, thus we can use 1. Session numbers must be unique per ENI, not globally.
  network_interface_id     = aws_instance.windows-server[count.index].primary_network_interface_id
  traffic_mirror_filter_id = var.vns_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.vns_va_traffic_mirror_target_id

  tags = {
    Name          = "${var.environment}-windows-server-${count.index}-traffic-mirror-session"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-windows-server"
  }
}

resource "aws_ec2_traffic_mirror_session" "ddi_traffic_mirror_session_windows" {
  count = var.deep_discovery_inspector ? length(aws_instance.windows-server) : 0

  description              = "DDI Traffic mirror session - Windows Server"
  session_number           = 2
  network_interface_id     = aws_instance.windows-server[count.index].primary_network_interface_id
  traffic_mirror_filter_id = var.ddi_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.ddi_va_traffic_mirror_target_id

  tags = {
    Name          = "${var.environment}-windows-server-${count.index}-traffic-mirror-session"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-windows-server"
  }
}
