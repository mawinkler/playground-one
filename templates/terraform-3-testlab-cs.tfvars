# AWS Region
aws_region = "${aws_region}"

# AWS Keys
aws_access_key = "${aws_pgo_user_access_key}"
aws_secret_key = "${aws_pgo_user_secret_key}"

# Allow access to the environment from any location or restrict it to your public ip
access_ip = ${pgo_access_ip}

# Windows Username
windows_username = "admin"

# Environment Name
environment = "${environment_name}"

# AWS PGO Active Directory
active_directory = ${active_directory}
ami_apex_one_server = ""
ami_apex_one_central = ""
ami_windows_client = []

create_apex_one_server = true
create_apex_one_central = true
windows_client_count = 2

