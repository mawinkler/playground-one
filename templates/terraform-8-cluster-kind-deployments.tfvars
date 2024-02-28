# Environment Name
environment = "${environment_name}"

# Vision One
container_security = ${vision_one_cs_enabled}
api_key            = "${vision_one_api_key}"
cluster_policy     = "${vision_one_cs_policy}"

# Calico
calico = ${integrations_calico_enabled}

# Trivy
trivy = ${integrations_trivy_enabled}

# Prometheus
prometheus = ${integrations_prometheus_enabled}
grafana_admin_password = "${integrations_prometheus_grafana_password}"