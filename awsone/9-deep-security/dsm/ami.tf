# #############################################################################
# Look up the latest Ubuntu Focal 20.04 AMI
# #############################################################################
data "aws_ami" "rhel" {
    most_recent            = false
    owners                 = ["309956199498"] # RHEL

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
