output "loadbalancer_ip_system_monitor" {
  value = kubernetes_ingress_v1.system_monitor_ingress.status[0].load_balancer[0].ingress[0].ip
}

output "loadbalancer_ip_health_check" {
  value = kubernetes_ingress_v1.health_check_ingress.status[0].load_balancer[0].ingress[0].ip
}

output "loadbalancer_ip_hunger_check" {
  value = kubernetes_ingress_v1.hunger_check_ingress.status[0].load_balancer[0].ingress[0].ip
}
