# AWS Region
aws_region = "${aws_region}"

# Allow access to the environment from any location or restrict it to your public ip
# Example:
#   access_ip      = "<YOUR IP>/32"
access_ip = ${pgo_access_ip}

# Linux Username (Do not change)
linux_username = "ubuntu"

# Windows Username
windows_username = "admin"

# Create Linux instance(s)
create_linux = ${pgo_ec2_create_linux}

# Create Windows instance(s)
create_windows = ${pgo_ec2_create_windows}

# Environment Name
environment = "${aws_environment}"
