# #############################################################################
# Bastion Host
#   SSH tunnel
#   NGINX upstream proxy
# #############################################################################
resource "aws_instance" "bastion" {

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_id]
  iam_instance_profile   = var.ec2_profile
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-bastion"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "dsm"
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
