# #############################################################################
# Outputs
# #############################################################################
output "cluster_name" {
  description = "Cluster Name"
  value       = module.kind.cluster_name
}

output "kube_config" {
  value     = module.kind.kube_config
  sensitive = true
}

# output "cluster_endpoint" {
#   description = "Cluster Endpoint"
#   value       = module.kind.cluster_endpoint
# }

# output "cluster_key" {
#   description = "Cluster Key"
#   value       = module.kind.client_key
# }
