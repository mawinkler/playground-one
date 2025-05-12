# #############################################################################
# Look up the latest Service Gateway AMI
# #############################################################################
data "aws_ami" "sg_va" {
  most_recent = true
  owners      = ["679593333241"] # Trend Micro

  filter {
    name   = "name"
    values = ["sg-va-2*"]
  }
}
