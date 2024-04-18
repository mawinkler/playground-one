output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_owner_id" {
  value = module.vpc.vpc_owner_id
}

output "public_security_group_id" {
  value = module.ec2.public_security_group_id
}

output "private_security_group_id" {
  value = module.ec2.private_security_group_id
}

output "public_security_group_inet_id" {
  value = module.ec2.public_security_group_inet_id
}

output "private_security_group_inet_id" {
  value = module.ec2.private_security_group_inet_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "public_subnet_cidr_blocks" {
  value = module.vpc.public_subnet_cidr_blocks
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_subnet_cidr_blocks" {
  value = module.vpc.private_subnet_cidr_blocks
}

output "intra_subnets" {
  value = module.vpc.intra_subnets
}

output "intra_subnet_cidr_blocks" {
  value = module.vpc.intra_subnet_cidr_blocks
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "database_subnet_group" {
  value = module.vpc.database_subnet_group
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

output "nat_public_ip" {
  value = module.vpc.nat_public_ip
}
