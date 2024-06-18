# ####################################
# Container Security Life-cycle
# ####################################
resource "helm_release" "prometheus" {
  depends_on   = [kubernetes_namespace_v1.prometheus_namespace]
  repository   = "https://prometheus-community.github.io/helm-charts"
  chart        = "kube-prometheus-stack"
  name         = "prometheus"
  namespace    = var.namespace
  reuse_values = true
  force_update = true

  values = [
    "${file("prometheus/prometheus-overrides.yaml")}"
  ]

  # Prometheus
  set {
    name  = "prometheus.ingress.enabled"
    value = true
  }
  set {
    name  = "prometheus.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "contour"
  }
  set_list {
    name = "prometheus.ingress.paths"
    value = ["/"]
  }
  set {
    name  = "prometheus.ingress.hosts"
    value = "prometheus.corp.local"
  }

  # Grafana
  set {
    name  = "grafana.adminPassword"
    value = "${var.grafana_admin_password}"
  }
  set {
    name  = "grafana.ingress.enabled"
    value = true
  }
  set {
    name  = "grafana.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "contour"
  }
  set {
    name = "grafana.ingress.path"
    value = "/"
  }
  set {
    name  = "grafana.ingress.hosts"
    value = "grafana.corp.local"
  }

  # Alertmanager
  set {
    name  = "alertmanager.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "contour"
  }
  set {
    name  = "alertmanager.ingress.enabled"
    value = true
  }
  set {
    name  = "alertmanager.ingress.hosts"
    value = "alertmanager.corp.local"
  }
}

resource "kubectl_manifest" "prometheus_httpproxy" {
  yaml_body  = <<YAML
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: prometheus
  namespace: prometheus
spec:
  virtualhost:
    fqdn: prometheus.corp.local
  routes:
    - services:
      - name: prometheus-kube-prometheus-prometheus
        port: 9090
      # conditions:
      # - prefix: /prometheus
YAML
}

resource "kubectl_manifest" "grafana_httpproxy" {
  yaml_body  = <<YAML
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: grafana
  namespace: prometheus
spec:
  virtualhost:
    fqdn: grafana.corp.local
  routes:
    - services:
      - name: prometheus-grafana
        port: 80
      # conditions:
      # - prefix: /grafana
YAML
}

resource "kubectl_manifest" "alertmanager_httpproxy" {
  yaml_body  = <<YAML
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: alertmanager
  namespace: prometheus
spec:
  virtualhost:
    fqdn: alertmanager.corp.local
  routes:
    - services:
      - name: prometheus-kube-prometheus-alertmanager
        port: 9093
      # conditions:
      # - prefix: /grafana
YAML
}
# data "kubernetes_ingress_v1" "prometheus_grafana" {
#   depends_on   = [helm_release.prometheus]

#   metadata {
#     name = "prometheus-grafana"
#     namespace = var.namespace
#   }
# }

# data "kubernetes_ingress_v1" "prometheus_kube_prometheus_prometheus" {
#   depends_on   = [helm_release.prometheus]

#   metadata {
#     name = "prometheus-kube-prometheus-prometheus"
#     namespace = var.namespace
#   }
# }

# data "kubernetes_service_v1" "prometheus_grafana" {
#   depends_on   = [helm_release.prometheus]

#   metadata {
#     name = "prometheus-grafana"
#     namespace = var.namespace
#   }
# }

# data "kubernetes_service_v1" "prometheus_kube_prometheus_prometheus" {
#   depends_on   = [helm_release.prometheus]

#   metadata {
#     name = "prometheus-kube-prometheus-prometheus"
#     namespace = var.namespace
#   }
# }
