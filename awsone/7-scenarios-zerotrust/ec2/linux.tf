# #############################################################################
# Linux Instance (ASRM Scenario)
#   MYSQL
#   Vision One Server & Workload Protection
#   Atomic Launcher
# #############################################################################
resource "aws_instance" "linux-docker" {

  count = var.create_linux ? 1 : 0

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
    Configuration = "zt"
  }

  user_data = local.userdata_linux

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
