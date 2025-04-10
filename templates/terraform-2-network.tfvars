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

# PGO VPN Gateway
vpn_gateway = ${vpn_gateway}

# AWS PGO Active Directory
active_directory = ${active_directory}
ad_domain_name   = "${environment_name}.local"
ami_active_directory_dc = "${ami_active_directory_dc}"
ami_active_directory_ca = "${ami_active_directory_ca}"

# AWS Managed Active Directory
managed_active_directory = ${managed_active_directory}

# Vision One Security Gateway
service_gateway = ${service_gateway}
ami_service_gateway = "${ami_service_gateway}"

# Virtual Network Sensor
virtual_network_sensor = ${pgo_virtual_network_sensor_enabled}

vns_token = "${pgo_virtual_network_sensor_token}"

# Deep Discovery Inspector
deep_discovery_inspector = ${pgo_deep_discovery_inspector_enabled}
ami_deep_discovery_inspector = "${ami_deep_discovery_inspector}"

# Static IPs
pgo_dc_private_ip = "10.0.0.10"
pgo_ca_private_ip = "10.0.0.11"
pgo_sg_private_ip = "10.0.0.12"
pgo_vns_private_ip = "10.0.1.8"
pgo_ddi_private_ip = "10.0.1.9"
vpn_private_ip = "10.0.4.10"
