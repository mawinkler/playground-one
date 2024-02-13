output "loadbalancer_dns_java_goof" {
  value = kubernetes_ingress_v1.java_goof_ingress.status[0].load_balancer[0].ingress[0].hostname
}
