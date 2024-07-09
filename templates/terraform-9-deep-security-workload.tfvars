# AWS Region
aws_region = "${aws_region}"

# AWS Keys
aws_access_key = "${aws_pgo_user_access_key}"
aws_secret_key = "${aws_pgo_user_secret_key}"

# Environment Name
environment = "${environment_name}-dsm"

# Linux Username (Do not change)
linux_username_amzn = "ec2-user"
linux_username_ubnt = "ubuntu"

# Windows Username
windows_username = "admin"

# Create Linux instance(s)
create_linux = ${pgo_ec2_create_linux}

# Create Windows instance(s)
create_windows = ${pgo_ec2_create_windows}
