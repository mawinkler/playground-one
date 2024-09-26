locals {
  manager_version = "20.0.967"
  agent_version = "20.0.1-19250"

  dsm_properties = <<-EOT
    AddressAndPortsScreen.ManagerAddress=
    AddressAndPortsScreen.NewNode=True
    UpgradeVerificationScreen.Overwrite=False
    LicenseScreen.License.-1=${var.dsm_license}
    DatabaseScreen.DatabaseType=PostgreSQL
    DatabaseScreen.Hostname=${var.rds_address}
    DatabaseScreen.Transport=TCP
    DatabaseScreen.DatabaseName=${var.rds_name}
    DatabaseScreen.Username=${var.rds_username}
    DatabaseScreen.Password=${var.rds_password}
    AddressAndPortsScreen.ManagerPort=4119
    AddressAndPortsScreen.HeartbeatPort=4120
    CredentialsScreen.Administrator.Username=${var.dsm_username}
    CredentialsScreen.Administrator.Password=${var.dsm_password}
    CredentialsScreen.UseStrongPasswords=False
    SecurityUpdateScreen.UpdateComponents=True
    SecurityUpdateScreen.Proxy=False
    SecurityUpdateScreen.ProxyType=
    SecurityUpdateScreen.ProxyAddress=
    SecurityUpdateScreen.ProxyPort=
    SecurityUpdateScreen.ProxyAuthentication=False
    SecurityUpdateScreen.ProxyUsername=
    SecurityUpdateScreen.ProxyPassword=
    SoftwareUpdateScreen.UpdateSoftware=True
    SoftwareUpdateScreen.Proxy=False
    SoftwareUpdateScreen.ProxyType=
    SoftwareUpdateScreen.ProxyAddress=
    SoftwareUpdateScreen.ProxyPort=
    SoftwareUpdateScreen.ProxyAuthentication=False
    SoftwareUpdateScreen.ProxyUsername=
    SoftwareUpdateScreen.ProxyPassword=
    RelayScreen.Install=True
    RelayScreen.AntiMalware=False
    SmartProtectionNetworkScreen.EnableFeedback=False
  EOT

  dsm_bootstrap = <<-EOT
    #!/bin/bash

    # Patch ManagerAddress
    # sed -i '/^AddressAndPortsScreen.ManagerAddress=/ s/$/&'$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)'/' /home/ec2-user/dsm.properties
    sed -i '/^AddressAndPortsScreen.ManagerAddress=/ s/$/&'$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)'/' /home/ec2-user/dsm.properties

    # Download Agent Installers
    curl -fsSL https://files.trendmicro.com/products/deepsecurity/en/20.0/Manager-Linux-${local.manager_version}.x64.sh -o /home/ec2-user/dsm_install.sh

    agents='
      https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-amzn2-${local.agent_version}.aarch64.zip
      https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-amzn2-${local.agent_version}.x86_64.zip
      https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-amzn2023-${local.agent_version}.aarch64.zip
      https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-amzn2023-${local.agent_version}.x86_64.zip
      https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_20.04-${local.agent_version}.aarch64.zip
      https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_20.04-${local.agent_version}.x86_64.zip
      https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_22.04-${local.agent_version}.aarch64.zip
      https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_22.04-${local.agent_version}.x86_64.zip
      https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Windows-${local.agent_version}.x86_64.zip
    '

    for agent in $agents; do
      curl -fsSL $agent -O
    done

    # Install Deep Security Manager
    chmod +x /home/ec2-user/dsm_install.sh
    sudo /home/ec2-user/dsm_install.sh -q -varfile /home/ec2-user/dsm.properties
  EOT

  userdata_linux = templatefile("${path.module}/userdata_linux.tftpl", {
    s3_bucket = var.s3_bucket
  })
}
