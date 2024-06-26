# AWS Region
aws_region = "${aws_region}"

# Linux Username (Do not change)
linux_username = "ubuntu"

# Windows Username
windows_username = "admin"

# Create Linux instance(s)
create_linux = ${pgo_ec2_create_linux}

# Create Windows instance(s)
create_windows = ${pgo_ec2_create_windows}

# Create Database instance
create_database = ${pgo_ec2_create_database}

# Environment Name
environment = "${environment_name}"

# db1 Database
rds_name = "db1"
rds_username = "db1"

# Create Attack Path
create_attackpath = ${vision_one_asrm_create_attackpath}

# AWS PGO Active Directory
active_directory = ${active_directory}
