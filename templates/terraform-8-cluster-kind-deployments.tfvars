# Environment Name
environment = "${environment_name}"

# Vision One
container_security = ${vision_one_cs_enabled}
api_key            = "${vision_one_api_key}"
api_url            = "${vision_one_api_url}"
cluster_policy     = "${vision_one_cs_policy}"

# Calico
calico = false  #${integrations_calico_enabled}

# Trivy
trivy = ${integrations_trivy_enabled}

# MetalLB
metallb = false  #${integrations_metallb_enabled}

# Prometheus
prometheus = false  #${integrations_prometheus_enabled}
grafana_admin_password = "${integrations_prometheus_grafana_password}"