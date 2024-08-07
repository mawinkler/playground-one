# AWS Region
aws_region = "${aws_region}"

# AWS Keys
aws_access_key = "${aws_pgo_user_access_key}"
aws_secret_key = "${aws_pgo_user_secret_key}"

# Allow access to the environment from any location or restrict it to your public ip
access_ip = ${pgo_access_ip}

# Environment Name
environment = "${environment_name}-dsm"

# Path to Playground One
one_path = "${ONEPATH}"

# Linux Username (Do not change)
linux_username = "ec2-user"

# Deep Security Manager
dsm_license = "${deep_security_license}"
dsm_username = "${deep_security_username}"
dsm_password = "${deep_security_password}"

# Deep Security Database
rds_name = "deepsecurity"
rds_username = "dsm"

# Use PX License Server
px = ${px}

# Vision One Security Gateway
service_gateway = ${service_gateway}
