# #############################################################################
# Linux Instance (ASRM Scenario)
#   MYSQL
#   Vision One Server & Workload Protection
#   Atomic Launcher
# #############################################################################
resource "aws_instance" "linux-pap" {

  count = var.create_attackpath ? 1 : 0

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.linux_instance_type_pap
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_inet_id]
  iam_instance_profile   = var.ec2_profile_db
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-linux-pap"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }

  user_data = local.userdata_linux_pap

  connection {
    user        = var.linux_username
    host        = self.public_ip
    private_key = file("${var.private_key_path}")
  }
}
