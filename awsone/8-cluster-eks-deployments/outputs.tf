# #############################################################################
# Outputs
# #############################################################################
output "loadbalancer_dns_java_goof" {
  value = module.victims.loadbalancer_dns_java_goof
}

output "loadbalancer_dns_openssl3" {
  value = module.victims.loadbalancer_dns_openssl3
}

output "loadbalancer_dns_system_monitor" {
  description = "Loadbalancer System Monitor DNS name"
  value       = module.goat.loadbalancer_dns_system_monitor
}
