# #############################################################################
# Linux userdata
# #############################################################################
data "template_file" "linux_userdata" {
    template = <<EOF
#!/bin/bash

# install essential packages
yum install -y unzip

# install aws cli
curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update
rm -Rf /tmp/aws /tmp/awscliv2.zip

# download from s3
mkdir -p /home/ec2-user/download
/usr/local/bin/aws s3 cp s3://${var.s3_bucket}/download /home/ec2-user/download --recursive
chown ec2-user.ec2-user -R /home/ec2-user/download
    EOF
}