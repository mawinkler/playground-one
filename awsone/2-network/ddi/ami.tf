# #############################################################################
# Look up the latest Private Access Connector
# #############################################################################
data "aws_ami" "ddi_va" {
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
    values = ["Trend Micro Deep Discovery Inspector*"]
  }
}
