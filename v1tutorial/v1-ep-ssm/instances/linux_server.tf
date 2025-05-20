# #############################################################################
# Linux Instances
# #############################################################################
resource "aws_instance" "linux-server" {

  count = var.linux_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = var.private_subnets[0]
  vpc_security_group_ids = [var.private_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-linux-server-${count.index}"
    Environment   = "${var.environment}"
    Type          = "${var.environment}-linux-server"
  }

  user_data = local.userdata_linux
}

# AWS Systems Manager
resource "aws_ssm_association" "linux_server_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMServerAgent" ? var.linux_count : 0 : 0

  name = aws_ssm_document.server-agent-linux.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.linux-server[count.index].id]
  }

  tags = {
    Name          = "${var.environment}-linux-server-${count.index}-ssm-association"
    Environment   = "${var.environment}"
    Type          = "${var.environment}-linux-server"
  }
}

resource "aws_ssm_association" "linux_sensor_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMSensorAgent" ? var.linux_count : 0 : 0

  name = aws_ssm_document.sensor-agent-linux.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.linux-server[count.index].id]
  }

  tags = {
    Name          = "${var.environment}-linux-server-${count.index}-ssm-association"
    Environment   = "${var.environment}"
    Type          = "${var.environment}-linux-server"
  }
}
