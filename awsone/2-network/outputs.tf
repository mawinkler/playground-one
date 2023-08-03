output "vpc_id" {
  value = module.network.vpc_id
}

output "public_security_group_id" {
  value = module.ec2.public_security_group_id
}

output "private_security_group_id" {
  value = module.ec2.private_security_group_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "public_subnet_cidr_blocks" {
  value = module.network.public_subnet_cidr_blocks
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "private_subnet_cidr_blocks" {
  value = module.network.private_subnet_cidr_blocks
}

output "key_name" {
  value = module.ec2.key_name
}

output "public_key" {
  value = module.ec2.public_key
}

output "private_key_path" {
  value = module.ec2.private_key_path
}
