# AWS Region
aws_region = "${aws_region}"

# AWS Keys
aws_access_key = "${aws_pgo_user_access_key}"
aws_secret_key = "${aws_pgo_user_secret_key}"

# Allow access to the environment from any location or restrict it to your public ip
access_ip = ${pgo_access_ip}

# Windows Username
windows_username = "administrator"

# Environment Name
environment = "${environment_name}"

# AWS PGO Active Directory
active_directory = ${active_directory}
ami_apex_one = "${ami_apex_one}"
ami_apex_central = "${ami_apex_central}"
ami_windows_client = ${ami_windows_client}
ami_exchange = "${ami_exchange}"
ami_transport = "${ami_transport}"

create_apex_one = true
create_apex_central = true
windows_client_count = 2
create_exchange = true

# Linux Username (Do not change)
linux_username = "ec2-user"

# Deep Security
create_dsm = true
ami_bastion = "${ami_bastion}"
ami_dsm = "${ami_dsm}"
ami_postgresql = "${ami_postgresql}"

# Deep Security Manager
dsm_license = "${deep_security_license}"
dsm_username = "${deep_security_username}"
dsm_password = "${deep_security_password}"

# Deep Security Database
rds_name = "deepsecurity"
rds_username = "dsm"

# Static IPs
dsm_private_ip = "10.0.0.20"
bastion_private_ip = "10.0.4.11"
apex_central_private_ip = "10.0.0.23"
apex_one_private_ip = "10.0.0.22"
exchange_private_ip = "10.0.0.25"
transport_private_ip = "10.0.0.26"
windows_server_private_ip = "10.0.1.0"
postgresql_private_ip = "10.0.0.24"
