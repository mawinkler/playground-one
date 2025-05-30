# #############################################################################
# Linux Instances
# #############################################################################
resource "aws_instance" "linux-server" {

  count = var.linux_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.linux_instance_type
  subnet_id              = var.vpn_gateway ? var.private_subnets[1] : var.public_subnets[0]
  vpc_security_group_ids = var.vpn_gateway ? [var.private_security_group_id] : [var.public_security_group_id]
  iam_instance_profile   = var.ec2_profile
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-linux-server-${count.index}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-linux-server"
  }

  user_data = local.userdata_linux

  connection {
    user        = var.linux_username
    host        = coalesce(self.public_ip, self.private_ip)
    private_key = file("${var.private_key_path}")
  }
}

# AWS Systems Manager
resource "aws_ssm_association" "linux_server_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMServerAgent" ? var.linux_count : 0 : 0

  name = var.ssm_document_server_agent_linux

  targets {
    key    = "InstanceIds"
    values = [aws_instance.linux-server[count.index].id]
  }

  tags = {
    Name          = "${var.environment}-linux-server-${count.index}-ssm-association"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-linux-server"
  }
}

resource "aws_ssm_association" "linux_sensor_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMSensorAgent" ? var.linux_count : 0 : 0

  name = var.ssm_document_sensor_agent_linux

  targets {
    key    = "InstanceIds"
    values = [aws_instance.linux-server[count.index].id]
  }

  tags = {
    Name          = "${var.environment}-linux-server-${count.index}-ssm-association"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-linux-server"
  }
}

# Traffic Mirror
resource "aws_ec2_traffic_mirror_session" "vns_traffic_mirror_session_linux" {
  count = var.virtual_network_sensor ? length(aws_instance.linux-server) : 0

  description              = "VNS Traffic mirror session - linux Server"
  session_number           = 1
  network_interface_id     = aws_instance.linux-server[count.index].primary_network_interface_id
  traffic_mirror_filter_id = var.vns_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.vns_va_traffic_mirror_target_id

  tags = {
    Name          = "${var.environment}-linux-server-${count.index}-traffic-mirror-session"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-linux-server"
  }
}

resource "aws_ec2_traffic_mirror_session" "ddi_traffic_mirror_session_linux" {
  count = var.deep_discovery_inspector ? length(aws_instance.linux-server) : 0

  description              = "DDI Traffic mirror session - linux Server"
  session_number           = 2
  network_interface_id     = aws_instance.linux-server[count.index].primary_network_interface_id
  traffic_mirror_filter_id = var.ddi_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.ddi_va_traffic_mirror_target_id

  tags = {
    Name          = "${var.environment}-linux-server-${count.index}-traffic-mirror-session"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-linux-server"
  }
}
