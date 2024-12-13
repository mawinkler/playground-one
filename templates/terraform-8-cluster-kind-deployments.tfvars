# Environment Name
environment = "${environment_name}"

# AWS Keys
aws_access_key = "${aws_pgo_user_access_key}"
aws_secret_key = "${aws_pgo_user_secret_key}"

# Vision One
container_security      = ${vision_one_cs_enabled}
api_key                 = "${vision_one_api_key}"
api_url                 = "${vision_one_api_url}"
cluster_policy          = "${vision_one_cs_policy}"
cluster_policy_operator = "${vision_one_cs_policy_operator}"
group_id                = "${vision_one_cs_group_id}"

# Calico
calico = false  #${integrations_calico_enabled}

# Trivy
trivy = ${integrations_trivy_enabled}

# MetalLB
metallb = ${integrations_metallb_enabled}

# Prometheus
prometheus = false  #${integrations_prometheus_enabled}
grafana_admin_password = "${integrations_prometheus_grafana_password}"

# PGOWeb
pgoweb = ${integrations_pgoweb_enabled}
