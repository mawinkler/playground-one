# AWS Region
aws_region = "${aws_region}"

# Allow access to the environment from any location or restrict it to your public ip
# Example:
#   access_ip      = "<YOUR IP>/32"
access_ip = ${pgo_access_ip}

# Environment Name
environment = "${environment_name}"

# Path to Playground One
one_path = "${ONEPATH}"

# XDR for Containers deployed
# xdr_for_containers = ${xdr_for_containers}

# create attack path
create_attackpath = ${vision_one_asrm_create_attackpath}

# active directory
active_directory = ${active_directory}

# Vision One Security Gateway
service_gateway = ${service_gateway}
