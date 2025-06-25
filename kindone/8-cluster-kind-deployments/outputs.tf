# #############################################################################
# Outputs
# #############################################################################
# output "loadbalancer_dns_prometheus" {
#   description = "Loadbalancer Prometheus DNS name"
#   value       = var.prometheus ? module.prometheus[0].loadbalancer_dns_prometheus : null
# }

# output "loadbalancer_dns_grafana" {
#   description = "Loadbalancer Grafana DNS name"
#   value       = var.prometheus ? module.prometheus[0].loadbalancer_dns_grafana : null
# }

output "loadbalancer_port_forward" {
  description = "Loadbalancer Port Forward command"
  value       = var.metallb ? module.metallb[0].loadbalancer_port_forward : null
}
output "loadbalancer_ip_pgoweb" {
  description = "Loadbalancer PGOWeb IP address"
  value       = var.pgoweb ? module.pgoweb[0].loadbalancer_ip_pgoweb : null
}

output "loadbalancer_ip_range" {
  value = var.metallb ? module.metallb[0].loadbalancer_ip_range : null
}

output "argocd_admin_secret" {
  value     = var.argocd ? module.argocd[0].argocd_admin_secret : null
  sensitive = true
}
