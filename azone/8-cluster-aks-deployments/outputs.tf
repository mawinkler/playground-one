# #############################################################################
# Outputs
# #############################################################################
output "loadbalancer_dns_prometheus" {
  description = "Loadbalancer Prometheus DNS name"
  value       = var.prometheus ? module.prometheus[0].loadbalancer_dns_prometheus : null
}

output "loadbalancer_dns_grafana" {
  description = "Loadbalancer Grafana DNS name"
  value       = var.prometheus ? module.prometheus[0].loadbalancer_dns_grafana : null
}

output "policy_id" {
  value = module.container_security[0].policy_id
}
