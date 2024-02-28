# AWS Account ID
account_id = "${aws_account_id}"

# AWS Region
aws_region = "${aws_region}"

# Allow access to the environment from any location or restrict it to your public ip
# Example:
#   access_ip      = "<YOUR IP>/32"
access_ip = ${pgo_access_ip}

# Environment Name
environment = "${environment_name}"

# Create EC2
ecs_ec2 = ${pgo_ecs_create_ec2}

# Create Fargate Profile
ecs_fargate = ${pgo_ecs_create_fargate}

# # Workload Security
# ws_tenantid = "${vision_one_server_tenant_id}"
# ws_token    = "${vision_one_server_token}"
# ws_policyid = ${vision_one_server_policy_id}
