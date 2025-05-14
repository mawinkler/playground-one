# #############################################################################
# Windows Instances
# #############################################################################
resource "aws_instance" "windows-server" {

  count = var.windows_count

  ami                    = data.aws_ami.windows.id
  instance_type          = "t3.medium"
  subnet_id              = var.private_subnets[0]
  vpc_security_group_ids = [var.private_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-windows-server-${count.index}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-windows-server"
  }

  user_data = templatefile("${path.module}/templates/userdata_windows.tftpl", {
    windows_ad_user_name     = var.windows_username
    windows_ad_hostname      = "Member-${count.index}"
    windows_ad_safe_password = var.windows_ad_safe_password

    userdata_windows_winrm   = local.userdata_function_windows_winrm
    userdata_windows_ssh     = local.userdata_function_windows_ssh
    userdata_windows_aws     = local.userdata_function_windows_aws
  })
}

# Traffic Mirror
resource "aws_ec2_traffic_mirror_session" "vns_traffic_mirror_session_windows" {
  count = length(aws_instance.windows-server)

  description              = "VNS Traffic mirror session - Windows Server"
  session_number           = 1  # Session numbers must be unique per ENI, not globally.
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
