# #############################################################################
# Outputs
# #############################################################################
output "cluster_name" {
  description = "Cluster Name"
  value       = kind_cluster.kind.name
}

output "kube_config" {
  value     = yamldecode(kind_cluster.kind.kubeconfig)
  sensitive = true
}
