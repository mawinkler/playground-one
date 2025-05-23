# AWS Region
aws_region = "${aws_region}"

# AWS Keys
aws_access_key = "${aws_pgo_user_access_key}"
aws_secret_key = "${aws_pgo_user_secret_key}"

# Allow access to the environment from any location or restrict it to your public ip
access_ip = ${pgo_access_ip}

# PGO VPN Gateway
vpn_gateway = ${vpn_gateway}

# Linux Username (Do not change)
linux_username = "ubuntu"

# Windows Username
windows_username = "admin"

# Environment Name
environment = "${environment_name}"

# db1 Database
rds_name = "db1"
rds_username = "db1"

# Create Attack Path
create_attackpath = ${vision_one_asrm_create_attackpath}

# AWS PGO Active Directory
active_directory = ${active_directory}

# Virtual Network Sensor
virtual_network_sensor = ${pgo_virtual_network_sensor_enabled}

# Deep Discovery Inspector
deep_discovery_inspector = ${pgo_deep_discovery_inspector_enabled}

# Endpoint Security
agent_deploy = ${vision_one_endpoint_enabled}
agent_variant = "${vision_one_endpoint_type}"
