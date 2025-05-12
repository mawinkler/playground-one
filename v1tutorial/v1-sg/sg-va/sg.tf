# #############################################################################
# Create
#   Security Group
# #############################################################################
resource "aws_security_group" "sg_va" {
  name        = "service-gateway-va-sg"
  description = "Security Group for Service Gateway"
  vpc_id      = var.vpc_id

  tags = {
    Name          = "${var.environment}-sg-sg-va"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.sg_va.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "For accessing Service Gateway virtual appliance CLISH command"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.sg_va.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Service enabled queries for on-premises Active Directory servers, connected Trend Micro products (such as endpoint agents), Predictive Machine Learning, File Reputation Services, or Third-Party Integration"
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.sg_va.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Service enabled queries for on-premises Active Directory servers, connected Trend Micro products (such as endpoint agents), Predictive Machine Learning, File Reputation Services, or Third-Party Integration"
}

resource "aws_vpc_security_group_ingress_rule" "allow_wrs1" {
  security_group_id = aws_security_group.sg_va.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 5274
  to_port           = 5274
  ip_protocol       = "tcp"
  description       = "Web Reputation Services or Web Inspection Service queries"
}

resource "aws_vpc_security_group_ingress_rule" "allow_wrs2" {
  security_group_id = aws_security_group.sg_va.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 5275
  to_port           = 5275
  ip_protocol       = "tcp"
  description       = "Web Reputation Services or Web Inspection Service queries"
}

resource "aws_vpc_security_group_ingress_rule" "allow_forward_proxy" {
  security_group_id = aws_security_group.sg_va.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
  description       = "Forward Proxy Service listening port for connection"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ztsa" {
  security_group_id = aws_security_group.sg_va.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 8088
  to_port           = 8088
  ip_protocol       = "tcp"
  description       = "Zero Trust Secure Access On-Premises Gateway listening port for connection"
}
