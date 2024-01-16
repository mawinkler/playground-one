output "loadbalancer_ip_java_goof" {
  value = kubernetes_ingress_v1.java_goof_ingress.status[0].load_balancer[0].ingress[0].ip
}

output "loadbalancer_ip_openssl3" {
  value = kubernetes_ingress_v1.openssl3_ingress.status[0].load_balancer[0].ingress[0].ip
}
