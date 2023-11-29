# AWS Region
aws_region = "${aws_region}"

# Environment Name
environment = "${aws_environment}-dsm"

# Linux Username (Do not change)
linux_username = "ec2-user"

# Create Linux instance(s)
create_linux = ${pgo_ec2_create_linux}

# Create Windows instance(s)
create_windows = ${pgo_ec2_create_windows}
