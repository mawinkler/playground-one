# #############################################################################
# Outputs
# #############################################################################
output "cluster_id" {
  value = var.container_security ? module.container_security[0].cluster_id : null
}

output "cluster_apikey" {
  value     = var.container_security ? module.container_security[0].cluster_apikey : null
  sensitive = true
}

output "cluster_policy_id" {
  value = var.container_security ? module.container_security[0].cluster_policy_id : null
}
