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

  user_data = data.template_file.linux_userdata.rendered

  connection {
    user        = var.linux_username
    host        = self.public_ip
    private_key = file("${var.private_key_path}")
  }
}
