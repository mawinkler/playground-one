# #############################################################################
# Outputs
# #############################################################################
# output "loadbalancer_dns_prometheus" {
#   value = data.kubernetes_ingress_v1.prometheus_kube_prometheus_prometheus.status[0].load_balancer[0].ingress[0].hostname
# }

# output "loadbalancer_dns_grafana" {
#   value = data.kubernetes_ingress_v1.prometheus_grafana.status[0].load_balancer[0].ingress[0].hostname
# }

# output "loadbalancer_dns_prometheus" {
#   value = data.kubernetes_service_v1.prometheus_kube_prometheus_prometheus.status[0].load_balancer[0].ingress[0].hostname
# }

# output "loadbalancer_dns_grafana" {
#   value = data.kubernetes_service_v1.prometheus_grafana.status[0].load_balancer[0].ingress[0].hostname
# }