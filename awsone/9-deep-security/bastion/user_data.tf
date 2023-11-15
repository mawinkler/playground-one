# #############################################################################
# Linux userdata
# #############################################################################
data "template_file" "linux_userdata" {
    template = <<EOF
#!/bin/bash

# install essential packages
apt-get update
apt-get install -y unzip

# install aws cli
curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update
rm -Rf /tmp/aws /tmp/awscliv2.zip
    EOF
}