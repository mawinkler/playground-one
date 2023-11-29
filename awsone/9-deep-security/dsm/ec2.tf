# #############################################################################
# Linux Instance
#   MYSQL
#   Vision One Server & Workload Protection
#   Atomic Launcher
# #############################################################################
resource "aws_network_interface" "dsm" {
  subnet_id       = var.private_subnets[0]
  security_groups = [var.private_security_group_id]
  private_ips     = ["10.0.0.100"]
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "dsm" {
  ami                  = data.aws_ami.rhel.id
  instance_type        = "t3.xlarge"
  iam_instance_profile = var.ec2_profile
  key_name             = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.dsm.id
    device_index         = 0
  }

  tags = {
    Name          = "${var.environment}-dsm"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "dsm"
  }

  user_data = data.template_file.linux_userdata.rendered

  connection {
    user             = var.linux_username
    host             = self.private_ip
    private_key      = file("${var.private_key_path}")
    bastion_host     = var.bastion_public_ip
    bastion_user     = "ubuntu"
    bastion_host_key = var.public_key
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

  # Download DSM installer, add public dns name to properties and install
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/20.0/Manager-Linux-20.0.844.x64.sh -o /home/ec2-user/dsm_install.sh",
      "curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-amzn2-20.0.0-8268.aarch64.zip -O",
      "curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-amzn2-20.0.0-8268.x86_64.zip -O",
      "curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-amzn2023-20.0.0-8268.aarch64.zip -O",
      "curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-amzn2023-20.0.0-8268.x86_64.zip -O",
      "curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_20.04-20.0.0-8268.aarch64.zip -O",
      "curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_20.04-20.0.0-8268.x86_64.zip -O",
      "curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_22.04-20.0.0-8268.aarch64.zip -O",
      "curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_22.04-20.0.0-8268.x86_64.zip -O",
      "curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Windows-20.0.0-8268.x86_64.zip -O",
      "chmod +x /home/ec2-user/dsm_install.sh",
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
      rid=$(curl --insecure -X POST https://${var.bastion_public_ip}:4119/api/sessions \
        -H 'Cache-Control: no-cache' \
        -H 'Content-Type: application/json' \
        -H 'api-version: v1' \
        -c cookie.txt -d '{"userName": "${var.dsm_username}", "password": "${var.dsm_password}"}' | \
        jq -r '.RID')
      
      curl --insecure -X POST https://${var.bastion_public_ip}:4119/api/apikeys \
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
