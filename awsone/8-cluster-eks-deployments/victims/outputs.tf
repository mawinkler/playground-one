output "loadbalancer_dns_java_goof" {
  value = kubernetes_ingress_v1.java_goof_ingress.status[0].load_balancer[0].ingress[0].hostname
}

output "loadbalancer_dns_openssl3" {
  value = kubernetes_ingress_v1.openssl3_ingress.status[0].load_balancer[0].ingress[0].hostname
}
