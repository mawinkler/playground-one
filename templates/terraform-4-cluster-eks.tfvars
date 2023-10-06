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

# Create Fargate Profile
# create_fargate_profile = ${pgo_eks_create_fargate_profile}
# temporarily disabled fargate profile
create_fargate_profile = false