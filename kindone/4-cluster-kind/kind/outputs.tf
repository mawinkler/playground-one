# #############################################################################
# Outputs
# #############################################################################
output "cluster_name" {
  description = "Cluster Name"
  value       = kind_cluster.kind.name
}

output "kube_config" {
  value     = kind_cluster.kind.
  sensitive = true
}

# output "cluster_endpoint" {
#   description = "Cluster Endpoint"
#   value       = kind_cluster.kind.endpoint
# }

# output "cluster_key" {
#   description = "Cluster Key"
#   value       = kind_cluster.kind.client_key
# }
