# #############################################################################
# Outputs
# #############################################################################
output "loadbalancer_ip_pgoweb" {
  value = kubernetes_ingress_v1.pgoweb_ingress.status[0].load_balancer[0].ingress[0].ip
}