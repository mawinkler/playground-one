# Allow access to the environment from any location or restrict it to your public ip
# Example:
#   access_ip      = "<YOUR IP>/32"
access_ip = ${ACCESS_IP}

# Environment Name
environment = "${AWS_ENVIRONMENT}"

# Cloud One
api_key            = "${CLOUD_ONE_API_KEY}"
cluster_policy     = "${CLOUD_ONE_POLICY_ID}"
cloud_one_region   = "${CLOUD_ONE_REGION}"
cloud_one_instance = "${CLOUD_ONE_INSTANCE}"
