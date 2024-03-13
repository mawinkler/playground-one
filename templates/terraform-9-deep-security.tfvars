# AWS Region
aws_region = "${aws_region}"

# Allow access to the environment from any location or restrict it to your public ip
# Example:
#   access_ip      = "<YOUR IP>/32"
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
