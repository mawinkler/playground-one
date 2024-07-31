# #############################################################################
# Linux Instance (ASRM Scenario)
#   MYSQL
#   Vision One Server & Workload Protection
#   Atomic Launcher
# #############################################################################
resource "aws_instance" "linux-db" {

  count = var.create_linux ? 1 : 0

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.linux_instance_type
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_id]
  iam_instance_profile   = var.ec2_profile
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-linux-db"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
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

  # v1 basecamp installation
  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/download/TMServerAgent_Linux_deploy.sh",
      "$HOME/download/TMServerAgent_Linux_deploy.sh"
    ]
  }
}

resource "aws_ec2_traffic_mirror_session" "vns_traffic_mirror_session_linux_db" {
  count = var.virtual_network_sensor && var.create_linux ? 1 : 0

  description              = "VNS Traffic mirror session - Linux DB"
  session_number           = 1
  network_interface_id     = aws_instance.linux-db[0].primary_network_interface_id
  traffic_mirror_filter_id = var.vns_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.vns_va_traffic_mirror_target_id
}
