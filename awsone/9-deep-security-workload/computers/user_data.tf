# #############################################################################
# Linux userdata
# #############################################################################
data "template_file" "linux_userdata" {
  template = <<EOF
    #!/bin/bash

    # install essential packages
    # apt-get update
    # apt-get install -y unzip
    yum install -y unzip

    # install aws cli
    curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
    unzip /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install --update
    rm -Rf /tmp/aws /tmp/awscliv2.zip

    # download from s3
    mkdir -p /home/ubuntu/download
    aws s3 cp s3://${var.s3_bucket}/download /home/ubuntu/download --recursive
    chown ubuntu.ubuntu -R /home/ubuntu/download

    curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/${local.deepsecurity_version}/${local.agent} -o /tmp/agent.zip
    unzip /tmp/agent.zip -d /tmp
    rpm -i /tmp/${local.agent}

    /opt/ds_agent/dsa_control -r
    /opt/ds_agent/dsa_control -a dsm://10.0.0.100:4120/ "policyid:6"
  EOF
}
