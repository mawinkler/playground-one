# #############################################################################
# Look up the latest Ubuntu Jammy 22.04 AMI
# #############################################################################
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  # filter {
  #     name = "kernel-id"
  #     values = ["5.15.0-1045"]
  # }
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
    # values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230517"]
  }
}

# #############################################################################
# Look up the latest Windows Server 2022 AMI
# #############################################################################
data "aws_ami" "windows" {
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
