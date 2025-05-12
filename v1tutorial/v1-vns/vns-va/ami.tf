# #############################################################################
# Look up the latest Virtual Network Sensor AMI
# #############################################################################
data "aws_ami" "vns_va" {
  most_recent = true
  owners      = ["679593333241"] # Trend Micro

  filter {
    name   = "name"
    values = ["Trend Vision One XDR for Networks Virtual Network Sensor*"]
  }
}
