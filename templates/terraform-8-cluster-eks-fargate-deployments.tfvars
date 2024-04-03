# Allow access to the environment from any location or restrict it to your public ip
# Example:
#   access_ip      = "<YOUR IP>/32"
access_ip = "${pgo_access_ip}"

# AWS Region
aws_region = "${aws_region}"

# Environment Name
environment = "${environment_name}"

# Vision One
container_security = ${vision_one_cs_enabled}
api_key            = "${vision_one_api_key}"
api_url            = "${vision_one_api_url}"
cluster_policy     = "${vision_one_cs_policy}"

# Calico
# calico = ${integrations_calico_enabled}
calico = false
