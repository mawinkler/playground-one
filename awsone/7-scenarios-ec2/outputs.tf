# #############################################################################
# Outputs
# #############################################################################
output "loadbalancer_dns_java_goof" {
  description = "Loadbalancer Java-Goof DNS name"
  value = module.victims.loadbalancer_dns_java_goof
}

output "loadbalancer_dns_system_monitor" {
  description = "Loadbalancer System Monitor DNS name"
  value       = module.goat.loadbalancer_dns_system_monitor
}

output "loadbalancer_dns_health_check" {
  description = "Loadbalancer Health Check DNS name"
  value       = module.goat.loadbalancer_dns_health_check
}

output "loadbalancer_dns_hunger_check" {
  description = "Loadbalancer Hunger Check DNS name"
  value       = module.goat.loadbalancer_dns_hunger_check
}
