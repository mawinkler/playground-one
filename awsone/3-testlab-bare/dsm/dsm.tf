# #############################################################################
# Linux Instance
#   MYSQL
#   Vision One Server & Workload Protection
#   Atomic Launcher
# #############################################################################
resource "aws_network_interface" "dsm" {
  subnet_id       = var.private_subnets[2]
  security_groups = [var.private_security_group_id]
  private_ips     = ["${var.dsm_private_ip}"]

  tags = {
    Name          = "${var.environment}-dsm-ni"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "testlab-bare"
  }
}

resource "aws_instance" "dsm" {

  ami                  = var.ami_dsm != "" ? var.ami_dsm : data.aws_ami.rhel.id
  instance_type        = "t3.xlarge"
  iam_instance_profile = var.ec2_profile
  key_name             = var.key_name

  root_block_device {
    volume_size = 20
  }

  network_interface {
    network_interface_id = aws_network_interface.dsm.id
    device_index         = 0
  }

  tags = {
    Name          = "${var.environment}-dsm"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "testlab-bare"
  }

  user_data = local.userdata_linux

  connection {
    user             = var.linux_username
    host             = self.private_ip
    private_key      = file("${var.private_key_path}")
  }

  # DSM properties file
  provisioner "file" {
    content     = local.dsm_properties
    destination = "dsm.properties"
  }

  provisioner "file" {
    content     = local.dsm_bootstrap
    destination = "dsm_bootstrap.sh"
  }

  # Bootstrap DSM
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/dsm_bootstrap.sh",
      "/home/ec2-user/dsm_bootstrap.sh"
    ]
  }
}

resource "random_string" "apikey_suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "null_resource" "create_apikey" {
  provisioner "local-exec" {
    command = <<-EOT
      rid=$(curl --insecure -X POST https://${aws_instance.dsm.private_ip}:4119/api/sessions \
        -H 'Cache-Control: no-cache' \
        -H 'Content-Type: application/json' \
        -H 'api-version: v1' \
        -c cookie.txt -d '{"userName": "${var.dsm_username}", "password": "${var.dsm_password}"}' | \
        jq -r '.RID')
      
      curl --insecure -X POST https://${aws_instance.dsm.private_ip}:4119/api/apikeys \
        -H 'Content-Type: application/json' \
        -H 'api-version: v1' \
        -H 'rID: '$rid \
        -b cookie.txt \
        -d '{"keyName": "Full Access ${random_string.apikey_suffix.result}", "roleID": 1}' | \
        jq -r -c '.secretKey' | tr -d '\n' > ${path.module}/apikey
    EOT
  }
  depends_on = [aws_instance.dsm]
}

data "local_file" "apikey" {
  filename   = "${path.module}/apikey"
  depends_on = [null_resource.create_apikey]
}
