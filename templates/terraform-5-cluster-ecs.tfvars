# AWS Account ID
account_id = "${AWS_ACCOUNT_ID}"

# AWS Region
aws_region = "${AWS_REGION}"

# Allow access to the environment from any location or restrict it to your public ip
# Example:
#   access_ip      = "<YOUR IP>/32"
access_ip = "${ACCESS_IP}"

# Environment Name
environment = "${AWS_ENVIRONMENT}"

# Create EC2
create_ec2 = ${ECS_CREATE_EC2}

# Create Fargate Profile
create_fargate = ${ECS_CREATE_FARGATE}

# Workload Security
ws_tenantid = "${WS_TENANTID}"
ws_token    = "${WS_TOKEN}"
ws_policyid = ${WS_POLICY}
