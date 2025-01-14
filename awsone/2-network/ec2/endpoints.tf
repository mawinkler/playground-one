data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3-endpt" {
  count           = var.private_subnet ? 1 : 0
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = [var.private_route_tables]
}

resource "aws_vpc_endpoint" "ssm-endpt" {
  count             = var.private_subnet ? 1 : 0
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_security_group.sg["private"].id
  ]
  subnet_ids          = [var.private_subnets[0]]
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
}

resource "aws_vpc_endpoint" "ssmmsgs-endpt" {
  count             = var.private_subnet ? 1 : 0
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_security_group.sg["private"].id
  ]
  subnet_ids          = [var.private_subnets[0]]
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
}

resource "aws_vpc_endpoint" "kms-endpt" {
  count             = var.private_subnet ? 1 : 0
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_security_group.sg["private"].id
  ]
  subnet_ids          = [var.private_subnets[0]]
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.kms"
}

resource "aws_vpc_endpoint" "cloudwatch-logs-endpt" {
  count             = var.private_subnet ? 1 : 0
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_security_group.sg["private"].id
  ]
  subnet_ids          = [var.private_subnets[0]]
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
}

resource "aws_vpc_endpoint" "ec2msgs-endpt" {
  count             = var.private_subnet ? 1 : 0
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_security_group.sg["private"].id
  ]
  subnet_ids          = [var.private_subnets[0]]
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
}

#### Create the CloudWatch log group for session logs ####

resource "aws_cloudwatch_log_group" "ssm_logs" {
  name_prefix       = "ssm-log-group-"
  retention_in_days = 30
  kms_key_id        = aws_kms_key.ssm_access_key.arn
}
