# #############################################################################
# Look up the latest Ubuntu Focal 20.04 AMI
# #############################################################################
# Working AMIs as of 20240502 in us-east-1:
# Amazon : ami-0fa6a49f8ee632a51
# Ubuntu : ami-011e48799a29115e9
# Windows: ami-0f496107db66676ff
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

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230814"]
  }
}

data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "aws_ami" "rhel" {
  most_recent = false
  owners      = ["309956199498"] # RHEL

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

  filter {
    name   = "name"
    values = ["RHEL-9.2.0_HVM-20230905-x86_64-38-Hourly2-GP2"]
  }
}

# #############################################################################
# Look up the latest Windows Server 2022 AMI
# #############################################################################
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

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
