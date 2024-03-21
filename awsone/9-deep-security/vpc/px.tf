# #############################################################################
# Platform Experience Licensing Server
# #############################################################################
#   EndpointInterface:
#     Type: AWS::EC2::VPCEndpoint
#     Properties:
#       SecurityGroupIds: 
#         - !Ref epiSecurityGroup
#       ServiceName: "com.amazonaws.vpce.us-east-1.vpce-svc-0e576abdce6c1b866"
#       SubnetIds: 
#         - !Ref PublicSubnet # change with your deep security instance subnet if needed
#       VpcEndpointType: "Interface"
#       VpcId: !Ref VPC
resource "aws_vpc_endpoint" "endpoint_interface" {
  count = var.px ? 1 : 0

  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.vpce.us-east-1.vpce-svc-0e576abdce6c1b866"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [module.vpc.public_subnets[0]]
  security_group_ids = [aws_security_group.epi_security_group.id]
}

#   Route53HostedZone:
#     Type: "AWS::Route53::HostedZone"
#     Properties: 
#       Name: 'licenseupdate.trendmicro.com'
#       VPCs: 
#       - 
#         VPCId: !Ref VPC
#         VPCRegion: 'us-east-1'
resource "aws_route53_zone" "route53_hosted_zone" {
  count = var.px ? 1 : 0

  name = "licenseupdate.trendmicro.com"

  vpc {
    vpc_id     = module.vpc.vpc_id
    vpc_region = "us-east-1"
  }
}

#   myDNS:
#     Type: AWS::Route53::RecordSetGroup
#     Properties:
#       HostedZoneName: licenseupdate.trendmicro.com.
#       RecordSets:
#       - Name: licenseupdate.trendmicro.com.
#         Type: A
#         AliasTarget:
#           HostedZoneId: !Select ['0', !Split [':', !Select ['0', !GetAtt EndpointInterface.DnsEntries]]]
#           DNSName: !Select ['1', !Split [':', !Select ['0', !GetAtt EndpointInterface.DnsEntries]]]
#     DependsOn: Route53HostedZone    
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

#   epiSecurityGroup:
#     Type: AWS::EC2::SecurityGroup
#     Properties:
#       GroupDescription: Enable inbound license check from deep security
#       SecurityGroupIngress:
#         - IpProtocol: tcp
#           FromPort: '80'
#           ToPort: '80'
#           CidrIp: 10.0.1.0/24 # change with your deep security subnet CIDR if needed
#       VpcId: !Ref VPC
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
