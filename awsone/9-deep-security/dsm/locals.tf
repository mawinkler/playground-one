locals {
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
    SmartProtectionNetworkScreen.EnableFeedback=False
  EOT

  dsm_bootstrap = <<-EOT
    #!/bin/bash

    # Patch ManagerAddress
    # sed -i '/^AddressAndPortsScreen.ManagerAddress=/ s/$/&'$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)'/' /home/ec2-user/dsm.properties
    sed -i '/^AddressAndPortsScreen.ManagerAddress=/ s/$/&'$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)'/' /home/ec2-user/dsm.properties

    # Install Deep Security Manager
    sudo /home/ec2-user/dsm_install.sh -q -varfile /home/ec2-user/dsm.properties
  EOT
}
