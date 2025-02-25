# AWS Region
aws_region = "${aws_region}"

# AWS Keys
aws_access_key = "${aws_pgo_user_access_key}"
aws_secret_key = "${aws_pgo_user_secret_key}"

# Allow access to the environment from any location or restrict it to your public ip
access_ip = ${pgo_access_ip}

# Environment Name
environment = "${environment_name}"

# Path to Playground One
one_path = "${ONEPATH}"

# Linux Username (Do not change)
linux_username = "ubuntu"

# Endpoint Security
agent_deploy = true
agent_variant = "TMServerAgent"
