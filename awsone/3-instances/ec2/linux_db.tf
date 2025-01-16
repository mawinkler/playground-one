# #############################################################################
# Linux Instance (ASRM Scenario)
#   MYSQL
#   Vision One Server & Workload Protection
#   Atomic Launcher
# #############################################################################
resource "aws_instance" "linux-db" {

  count = var.create_linux ? var.linux_db_count : 0

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.linux_instance_type
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_id]
  iam_instance_profile   = var.ec2_profile
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-linux-db-${count.index}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
    Type          = "${var.environment}-linux-server"
  }

  user_data = local.userdata_linux_db

  connection {
    user        = var.linux_username
    host        = self.public_ip
    private_key = file("${var.private_key_path}")
  }

  # mysql installation
  provisioner "file" {
    source      = "../1-scripts/mysql.sh"
    destination = "/tmp/mysql.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/mysql.sh",
      "sudo /tmp/mysql.sh"
    ]
  }
}

# AWS Systems Manager
resource "aws_ssm_association" "linux_db_server_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMServerAgent" ? var.linux_db_count : 0 : 0

  name = aws_ssm_document.server-agent-linux.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.linux-db[count.index].id]
  }
}

resource "aws_ssm_association" "linux_db_sensor_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMSensorAgent" ? var.linux_db_count : 0 : 0

  name = aws_ssm_document.sensor-agent-linux.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.linux-web[count.index].id]
  }
}

# Traffic Mirror
resource "aws_ec2_traffic_mirror_session" "vns_traffic_mirror_session_linux_db" {
  count = var.virtual_network_sensor && var.create_linux ? 1 : 0

  description              = "VNS Traffic mirror session - Linux DB"
  session_number           = 1
  network_interface_id     = aws_instance.linux-db[0].primary_network_interface_id
  traffic_mirror_filter_id = var.vns_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.vns_va_traffic_mirror_target_id
}

resource "aws_ec2_traffic_mirror_session" "ddi_traffic_mirror_session_linux_db" {
  count = var.deep_discovery_inspector && var.create_linux ? 1 : 0

  description              = "DDI Traffic mirror session - Linux DB"
  session_number           = 1
  network_interface_id     = aws_instance.linux-db[0].primary_network_interface_id
  traffic_mirror_filter_id = var.ddi_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.ddi_va_traffic_mirror_target_id
}
