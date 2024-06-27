# #############################################################################
# Linux Instance (ASRM Scenario)
#   MYSQL
#   Vision One Server & Workload Protection
#   Atomic Launcher
# #############################################################################
resource "aws_instance" "linux-db" {

  count = var.create_linux ? 1 : 0

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_inet_id]
  iam_instance_profile   = var.ec2_profile_db
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
