# #############################################################################
# Look up the latest Ubuntu Focal 20.04 AMI
# #############################################################################
data "aws_ami" "vns_va" {
  most_recent = true
  owners      = ["679593333241"] # Trend Micro

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
    values = ["Trend Vision One XDR for Networks Virtual Network Sensor*"]
  }
}
