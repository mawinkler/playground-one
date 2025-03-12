# #############################################################################
# Look up the latest Ubuntu Jammy 22.04 arm64 AMI
# #############################################################################
data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
}
