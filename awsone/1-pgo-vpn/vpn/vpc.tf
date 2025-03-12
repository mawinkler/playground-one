# #############################################################################
# Getting VPC and Subnets
# #############################################################################
locals {
  vpc_name = "pgo-cs-vpc" # Change this to yor VPC name
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  # tags = { Tier = "Public" } # This is custom tag
  tags = { public = 1 } # This is custom tag
}
