# #############################################################################
# Outputs
# #############################################################################
output "cluster_name_ec2" {
  description = "ECS Cluster Name"
  value       = var.ecs_ec2 ? module.ecs-ec2.cluster_name : null
}

output "loadbalancer_dns_ec2" {
  description = "ECS Loadbalancer DNS name"
  value       = var.ecs_ec2 ? module.ecs-ec2.loadbalancer_dns : null
}

output "cluster_name_fargate" {
  description = "ECS Cluster Name"
  value       = var.ecs_fargate ? module.ecs-fargate[0].cluster_name : null
}

output "loadbalancer_dns_fargate" {
  description = "ECS Loadbalancer DNS name"
  value       = var.ecs_fargate ? module.ecs-fargate[0].loadbalancer_dns : null
}