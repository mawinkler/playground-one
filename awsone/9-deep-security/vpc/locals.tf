################################################################################
# Locals
################################################################################
locals {
  name = "${var.environment}-vpc"

  vpc_cidr = "10.0.0.0/16"
  azs      = var.px ? slice(data.aws_availability_zones.available_px[0].names, 0, 2) : slice(data.aws_availability_zones.available[0].names, 0, 2)
}
