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
  # set {
  #   name  = "prometheus.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
  #   value = "internet-facing"
  # }
  # set {
  #   name  = "prometheus.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
  #   value = "ip"
  # }
  set {
    name  = "prometheus.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }
  # set {
  #   name  = "prometheus.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/inbound-cidrs"
  #   value = var.access_ip
  # }
  set_list {
    name = "prometheus.ingress.paths"
    value = ["/*"]
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
  # set {
  #   name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
  #   value = "internet-facing"
  # }
  # set {
  #   name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
  #   value = "ip"
  # }
  set {
    name  = "grafana.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }
  # set {
  #   name  = "grafana.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/inbound-cidrs"
  #   value = var.access_ip
  # }
  set {
    name = "grafana.ingress.path"
    value = "/"
  }
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

resource "kubectl_manifest" "prometheus_httpproxy" {
  yaml_body  = <<YAML
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: prometheus
  namespace: prometheus
spec:
  virtualhost:
    fqdn: localhost
  routes:
    - services:
      - name: prometheus-kube-prometheus-prometheus
        port: 9090
      # conditions:
      # - prefix: /prometheus
    # - services:
    #   - name: prometheus-grafana
    #     port: 80
    #   conditions:
    #   - prefix: /grafana
YAML
}

# resource "kubectl_manifest" "grafana_httpproxy" {
#   yaml_body  = <<YAML
# apiVersion: projectcontour.io/v1
# kind: HTTPProxy
# metadata:
#   name: grafana
#   namespace: prometheus
# spec:
#   virtualhost:
#     fqdn: grafana.localhost
#   routes:
#     - services:
#       - name: prometheus-grafana
#         port: 80
#       # conditions:
#       # - prefix: /grafana
# YAML
# }