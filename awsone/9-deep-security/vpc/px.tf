# #############################################################################
# Platform Experience Licensing Server
# #############################################################################
# Find the public subnet in availability zone id use1-az1
data "aws_subnet" "subnet_use1_az1" {
  depends_on = [module.vpc.public_subnets]

  filter {
    name   = "availability-zone-id"
    values = ["use1-az1"]
  }
  filter {
    name   = "tag:public"
    values = ["1"]
  }
}

resource "aws_vpc_endpoint" "endpoint_interface" {
  count = var.px ? 1 : 0

  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.vpce.us-east-1.vpce-svc-0e576abdce6c1b866"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [data.aws_subnet.subnet_use1_az1.id]
  security_group_ids = [aws_security_group.epi_security_group.id]
}

resource "aws_route53_zone" "route53_hosted_zone" {
  count = var.px ? 1 : 0

  name = "licenseupdate.trendmicro.com"

  vpc {
    vpc_id     = module.vpc.vpc_id
    vpc_region = "us-east-1"
  }
}

resource "aws_route53_record" "licenseupdate_dns" {
  count = var.px ? 1 : 0

  depends_on = [aws_route53_zone.route53_hosted_zone]
  zone_id    = aws_route53_zone.route53_hosted_zone[0].zone_id
  name       = "licenseupdate.trendmicro.com"
  type       = "A"

  alias {
    zone_id                = aws_vpc_endpoint.endpoint_interface[0].dns_entry[0].hosted_zone_id
    name                   = aws_vpc_endpoint.endpoint_interface[0].dns_entry[0].dns_name
    evaluate_target_health = false
  }
}

resource "aws_security_group" "epi_security_group" {
  name        = "epi-sg"
  description = "Enable inbound license check from deep security"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }
}
