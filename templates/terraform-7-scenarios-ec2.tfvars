# Allow access to the environment from any location or restrict it to your public ip
# Example:
#   access_ip      = "<YOUR IP>/32"
access_ip = "${pgo_access_ip}"

# AWS Region
aws_region = "${aws_region}"

# Environment Name
environment = "${aws_environment}"