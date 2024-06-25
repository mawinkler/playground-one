# #############################################################################
# Outputs
# #############################################################################
output "cluster_name_fargate" {
  description = "ECS Cluster Name"
  value       = module.ecs-fargate.cluster_name
}

output "loadbalancer_dns_fargate" {
  description = "ECS Loadbalancer DNS name"
  value       = module.ecs-fargate.loadbalancer_dns
}
