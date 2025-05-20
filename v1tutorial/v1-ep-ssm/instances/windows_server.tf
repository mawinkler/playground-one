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
    Type          = "${var.environment}-windows-server"
  }

  user_data = templatefile("${path.module}/templates/userdata_windows.tftpl", {
    s3_bucket                = var.s3_bucket
    windows_ad_user_name     = var.windows_username
    windows_ad_hostname      = "Member-${count.index}"
    windows_ad_safe_password = var.windows_ad_safe_password
    windows_ad_domain_name   = ""
    tm_agent                 = var.agent_variant

    userdata_windows_winrm   = local.userdata_function_windows_winrm
    userdata_windows_ssh     = local.userdata_function_windows_ssh
    userdata_windows_aws     = local.userdata_function_windows_aws
  })
}

# AWS Systems Manager
resource "aws_ssm_association" "windows_server_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMServerAgent" ? var.windows_count : 0 : 0

  name = aws_ssm_document.server-agent-windows.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.windows-server[count.index].id]
  }

  tags = {
    Name          = "${var.environment}-windows-server-${count.index}-ssm-association"
    Environment   = "${var.environment}"
    Type          = "${var.environment}-windows-server"
  }
}

resource "aws_ssm_association" "windows_sensor_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMSensorAgent" ? var.windows_count : 0 : 0

  name = aws_ssm_document.sensor-agent-windows.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.windows-server[count.index].id]
  }

  tags = {
    Name          = "${var.environment}-windows-server-${count.index}-ssm-association"
    Environment   = "${var.environment}"
    Type          = "${var.environment}-windows-server"
  }
}
