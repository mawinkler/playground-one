# Allow access to the environment from any location or restrict it to your public ip
# Example:
#   access_ip      = "<YOUR IP>/32"
access_ip = "${pgo_access_ip}"

# Environment Name
environment = "${aws_environment}"

# Cloud One
api_key            = "${cloud_one_api_key}"
container_security = ${cloud_one_cs_enabled}
cluster_policy     = "${cloud_one_cs_policy_id}"
cloud_one_region   = "${cloud_one_region}"
cloud_one_instance = "${cloud_one_instance}"

# Trivy
trivy = true
