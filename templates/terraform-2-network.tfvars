# AWS Account ID
account_id = "${aws_account_id}"

# AWS Region
aws_region = "${aws_region}"

# Allow access to the environment from any location or restrict it to your public ip
# Example:
#   access_ip      = "<YOUR IP>/32"
access_ip = ${pgo_access_ip}

# Environment Name
environment = "${aws_environment}"

# Path to Playground One
one_path = "${ONEPATH}"

# XDR for Containers deployed
xdr_for_containers = ${xdr_for_containers}
