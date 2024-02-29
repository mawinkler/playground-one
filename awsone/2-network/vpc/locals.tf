################################################################################
# Locals
################################################################################
locals {
  name = "${var.environment}-vpc"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  s3_bucket_name = "${var.environment}-vpc-flow-logs-${random_pet.this.id}"
}

resource "random_pet" "this" {
  length = 2
}
