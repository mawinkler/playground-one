output "loadbalancer_dns_system_monitor" {
  value = kubernetes_ingress_v1.system_monitor_ingress.status[0].load_balancer[0].ingress[0].hostname
}

output "loadbalancer_dns_health_check" {
  value = kubernetes_ingress_v1.health_check_ingress.status[0].load_balancer[0].ingress[0].hostname
}
