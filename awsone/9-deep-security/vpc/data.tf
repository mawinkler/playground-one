################################################################################
# Data
################################################################################
data "aws_availability_zones" "available" {
  count = var.px ? 0 : 1
}

data "aws_availability_zones" "available_px" {
  count = var.px ? 1 : 0

  filter {
    name   = "zone-id"
    values = ["use1-az1", "use1-az2"]
  }
}
