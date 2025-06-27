# Allow access to the environment from any location or restrict it to your public ip
access_ip = "${pgo_access_ip}"

# AWS Keys
aws_access_key = "${aws_pgo_user_access_key}"
aws_secret_key = "${aws_pgo_user_secret_key}"

# AWS Region
aws_region = "${aws_region}"

# Environment Name
environment = "${environment_name}"

# Vision One
container_security      = ${vision_one_cs_enabled}
api_key                 = "${vision_one_api_key}"
api_url                 = "${vision_one_api_url}"
registration_key        = "${vision_one_cs_registration_key}"
cluster_policy          = "${vision_one_cs_policy}"
cluster_policy_operator = "${vision_one_cs_policy_operator}"
group_id                = "${vision_one_cs_group_id}"

# Calico
calico = ${integrations_calico_enabled}

# Trivy
trivy = ${integrations_trivy_enabled}

# Prometheus
prometheus = ${integrations_prometheus_enabled}
grafana_admin_password = "${integrations_prometheus_grafana_password}"

# Istio
istio = ${integrations_istio_enabled}

# PGOWeb
pgoweb = ${integrations_pgoweb_enabled}
