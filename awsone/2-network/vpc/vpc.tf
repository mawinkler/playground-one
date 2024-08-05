# #############################################################################
# Create VPC
# #############################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8.1"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 20)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 24)]

  private_subnet_names = [for i in local.azs : "${var.environment}-private-subnet-${i}"]
  public_subnet_names  = [for i in local.azs : "${var.environment}-public-subnet-${i}"]
  intra_subnet_names   = [for i in local.azs : "${var.environment}-intra-subnet-${i}"]
  database_subnet_names = [for i in local.azs : "${var.environment}-database-subnet-${i}"]

  create_database_subnet_group = true

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  instance_tenancy = "default"

  enable_nat_gateway = true
  single_nat_gateway = true
  create_igw         = true

  map_public_ip_on_launch = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  # flow_log_max_aggregation_interval    = 60

  tags = {
    # Name          = "${var.environment}-vpc"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }

  intra_subnet_tags = {
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
}
