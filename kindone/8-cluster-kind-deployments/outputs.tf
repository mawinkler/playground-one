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

# output "cluster_id" {
#   value = var.container_security ? module.container_security[0].cluster_id : null
# }

# output "cluster_apikey" {
#   value     = var.container_security ? module.container_security[0].cluster_apikey : null
#   sensitive = true
# }

# output "cluster_policy_id" {
#   value = var.container_security ? module.container_security[0].cluster_policy_id : null
# }
