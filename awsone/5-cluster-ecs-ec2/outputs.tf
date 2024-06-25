# #############################################################################
# Outputs
# #############################################################################
output "cluster_name_ec2" {
  description = "ECS Cluster Name"
  value       = module.ecs-ec2.cluster_name
}

output "loadbalancer_dns_ec2" {
  description = "ECS Loadbalancer DNS name"
  value       = module.ecs-ec2.loadbalancer_dns
}

output "ecs_ami_ec2" {
  description = "ECS AMI"
  value       = module.ecs-ec2.ecs_ami
}
