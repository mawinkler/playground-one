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
