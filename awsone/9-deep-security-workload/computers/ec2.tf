# #############################################################################
# Linux Instance
#   Nginx
#   Wordpress
#   Vision One Server & Workload Protection
#   Atomic Launcher
# #############################################################################
resource "aws_instance" "linux1" {

  count = var.create_linux ? 1 : 0

  ami                    = data.aws_ami.amzn2.id
  instance_type          = "t3.medium"
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_id]
  iam_instance_profile   = var.ec2_profile
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-linux1"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "dsm"
  }

  user_data = data.template_file.linux_userdata_amzn.rendered

  connection {
    user        = var.linux_username_amzn
    host        = self.public_ip
    private_key = file("${var.private_key_path}")
  }
}

resource "aws_instance" "linux2" {

  count = var.create_linux ? 1 : 0

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_id]
  iam_instance_profile   = var.ec2_profile
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-linux2"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "dsm"
  }

  user_data = data.template_file.linux_userdata_deb.rendered

  connection {
    user        = var.linux_username_ubnt
    host        = self.public_ip
    private_key = file("${var.private_key_path}")
  }
}

resource "random_password" "windows_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_instance" "windows1" {

  count = var.create_linux ? 1 : 0

  ami                    = data.aws_ami.windows.id
  instance_type          = "t3.medium"
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_id]
  iam_instance_profile   = var.ec2_profile
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-windows1"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "dsm"
  }

  user_data = data.template_file.windows_userdata.rendered

  connection {
    host     = coalesce(self.public_ip, self.private_ip)
    type     = "winrm"
    port     = 5986
    user     = var.windows_username
    password = random_password.windows_password.result
    https    = true
    insecure = true
    timeout  = "13m"
  }
}
