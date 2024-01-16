# #############################################################################
# Outputs
# #############################################################################
output "loadbalancer_ip_java_goof" {
  description = "Loadbalancer Java-Goof DNS name"
  value = module.victims.loadbalancer_ip_java_goof
}

output "loadbalancer_ip_openssl3" {
  description = "Loadbalancer OpenSSL DNS name"
  value = module.victims.loadbalancer_ip_openssl3
}

output "loadbalancer_ip_system_monitor" {
  description = "Loadbalancer System Monitor DNS name"
  value       = module.goat.loadbalancer_ip_system_monitor
}

output "loadbalancer_ip_health_check" {
  description = "Loadbalancer Health Check DNS name"
  value       = module.goat.loadbalancer_ip_health_check
}

output "loadbalancer_ip_hunger_check" {
  description = "Loadbalancer Hunger Check DNS name"
  value       = module.goat.loadbalancer_ip_hunger_check
}
