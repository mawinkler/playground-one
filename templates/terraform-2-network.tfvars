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

# XDR for Containers deployed
# xdr_for_containers = ${xdr_for_containers}

# AWS Managed Active Directory
managed_active_directory = ${managed_active_directory}

# AWS PGO Active Directory
active_directory = ${active_directory}
ad_domain_name   = "${environment_name}.local"

# Vision One Security Gateway
service_gateway = ${service_gateway}

# Virtual Network Sensor
virtual_network_sensor = ${pgo_virtual_network_sensor_enabled}

vns_token = "${pgo_virtual_network_sensor_token}"
