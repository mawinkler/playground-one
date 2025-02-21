# #############################################################################
# Linux Instance
#   Nginx
#   Wordpress
#   Vision One Server & Workload Protection
#   Atomic Launcher
# #############################################################################
resource "aws_instance" "pgo-satellite" {

  count = var.create_linux ? var.pgo_satellite_count : 0

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.pgo_instance_type
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.sg["public"].id]
  iam_instance_profile   = var.ec2_profile
  key_name               = aws_key_pair.key_pair.key_name

  root_block_device {
    volume_size           = 20
  }

  tags = {
    Name          = "${var.environment}-pgo-satellite-${count.index}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "satellite"
    Type          = "${var.environment}-linux-server"
  }

  user_data = local.userdata_pgo_satellite

  connection {
    user        = var.linux_username
    host        = self.public_ip
    private_key = file("${local_file.ssh_key.filename}")
  }

  # Copy config.yaml to satellite
  provisioner "file" {
    source      = "../../config.yaml"
    destination = "/home/${var.linux_username}/config.yaml"
  }
}

# AWS Systems Manager
resource "aws_ssm_association" "linux_satellite_server_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMServerAgent" ? var.pgo_satellite_count : 0 : 0

  name = aws_ssm_document.server-agent-linux.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.pgo-satellite[count.index].id]
  }
}

resource "aws_ssm_association" "linux_satellite_sensor_agent" {
  count = var.agent_deploy ? var.agent_variant == "TMSensorAgent" ? var.pgo_satellite_count : 0 : 0

  name = aws_ssm_document.sensor-agent-linux.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.pgo-satellite[count.index].id]
  }
}
