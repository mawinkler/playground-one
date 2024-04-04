output "url_java_goof" {
  value = "http://${kubernetes_ingress_v1.java_goof_ingress.status[0].load_balancer[0].ingress[0].ip}/todolist"
}
