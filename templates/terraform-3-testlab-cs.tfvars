# AWS Region
aws_region = "${aws_region}"

# AWS Keys
aws_access_key = "${aws_pgo_user_access_key}"
aws_secret_key = "${aws_pgo_user_secret_key}"

# Allow access to the environment from any location or restrict it to your public ip
access_ip = ${pgo_access_ip}

# Windows Username
windows_username = "admin"

# Environment Name
environment = "${environment_name}"

# AWS PGO Active Directory
active_directory = ${active_directory}
ami_apex_one_server = "${ami_apex_one_server}"
ami_apex_one_central = "${ami_apex_one_central}"
ami_windows_client = ${ami_windows_client}

create_apex_one_server = true
create_apex_one_central = true
windows_client_count = 2

# Linux Username (Do not change)
linux_username = "ec2-user"

# Deep Security
create_dsm = false
ami_bastion = "${ami_bastion}"
ami_dsm = "${ami_dsm}"

# Deep Security Manager
dsm_license = "${deep_security_license}"
dsm_username = "${deep_security_username}"
dsm_password = "${deep_security_password}"

# Deep Security Database
rds_name = "deepsecurity"
rds_username = "dsm"
