# #############################################################################
# Bastion Host
#   SSH tunnel
#   NGINX upstream proxy
# #############################################################################
resource "aws_network_interface" "bastion_eni" {
  subnet_id       = var.public_subnets[0]
  private_ips     = ["10.0.4.11"]
  security_groups = [var.public_security_group_id]
}

resource "aws_instance" "bastion" {

  ami                    = var.ami_bastion != "" ? var.ami_bastion : data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  iam_instance_profile   = var.ec2_profile
  key_name               = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.bastion_eni.id
    device_index         = 0 # Primary network interface
  }

  tags = {
    Name          = "${var.environment}-bastion"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "testlab-cs"
  }

  user_data = local.userdata_linux

  connection {
    user        = var.linux_username
    host        = self.public_ip
    private_key = file("${var.private_key_path}")
  }

  provisioner "file" {
    content     = local.passthrough_conf
    destination = "/tmp/passthrough.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash -c \"timeout 300 sed '/finished-user-data/q' <(tail -f /var/log/cloud-init-output.log)\"",
      "sudo mv /tmp/passthrough.conf /etc/nginx/passthrough.conf",
      "sudo chown root.root /etc/nginx/passthrough.conf",
      "sudo nginx -t",
      "sudo service nginx restart"
    ]
  }
}
