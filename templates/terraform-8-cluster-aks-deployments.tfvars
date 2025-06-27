# Subscription ID
subscription_id = "${azure_subscription_id}"

# Allow access to the environment from any location or restrict it to your public ip
access_ip = "${pgo_access_ip}"

# Environment Name
environment = "${environment_name}"

# Vision One
container_security      = ${vision_one_cs_enabled}
api_key                 = "${vision_one_api_key}"
api_url                 = "${vision_one_api_url}"
registration_key        = "${vision_one_cs_registration_key}"
cluster_policy          = "${vision_one_cs_policy}"
cluster_policy_operator = "${vision_one_cs_policy_operator}"

# Calico
calico = false  #${integrations_calico_enabled}

# Trivy
trivy = false  #${integrations_trivy_enabled}

# Prometheus
prometheus = false  #${integrations_prometheus_enabled}
grafana_admin_password = "${integrations_prometheus_grafana_password}"