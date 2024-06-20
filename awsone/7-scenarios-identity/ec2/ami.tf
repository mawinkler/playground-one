# #############################################################################
# Look up the latest Windows Server 2022 AMI
# #############################################################################
data "aws_ami" "windows-server" {
  most_recent = true
  owners      = ["amazon"]

  # "Name=platform,Values=windows"
  # "Name=architecture,Values=x86_64"
  # "Name=root-device-type,Values=ebs"
  # "Name=name,Values=Windows_Server-2022-English-Full-Base*"

  filter {
    name   = "platform"
    values = ["windows"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }
}
