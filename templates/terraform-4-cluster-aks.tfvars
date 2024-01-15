# Subscription ID
subscription_id = "${azure_subscription_id}"

# Allow access to the environment from any location or restrict it to your public ip
# Example:
#   access_ip      = "<YOUR IP>/32"
access_ip = ${pgo_access_ip}

# Environment Name
environment = "${azure_environment}"

# Azure Region
resource_group_location = "${azure_region}"

# Node count
node_count = 3

# Node username
username = "azureadmin"