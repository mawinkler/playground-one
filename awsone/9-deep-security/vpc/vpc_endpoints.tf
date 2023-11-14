################################################################################
# VPC Endpoints Module
################################################################################

# module "vpc_endpoints" {
#   source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

#   vpc_id = module.vpc.vpc_id

#   create_security_group      = true
#   security_group_name_prefix = "${local.name}-vpc-endpoints-"
#   security_group_description = "VPC endpoint security group"
#   security_group_rules = {
#     ingress_https = {
#       description = "HTTPS from VPC"
#       cidr_blocks = [module.vpc.vpc_cidr_block]
#     }
#   }

#   endpoints = {
#     s3 = {
#       service = "s3"
#       tags    = { Name = "s3-vpc-endpoint" }
#     },
#     # dynamodb = {
#     #   service         = "dynamodb"
#     #   service_type    = "Gateway"
#     #   route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
#     #   policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
#     #   tags            = { Name = "dynamodb-vpc-endpoint" }
#     # },
#     ecs = {
#       service             = "ecs"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ecs_telemetry = {
#       create              = false
#       service             = "ecs-telemetry"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ecr_api = {
#       service             = "ecr.api"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
#     },
#     ecr_dkr = {
#       service             = "ecr.dkr"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
#     },
#     # rds = {
#     #   service             = "rds"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     #   security_group_ids  = [aws_security_group.rds.id]
#     # },
#   }

#   tags = merge(local.tags, {
#     Project  = "Secret"
#     Endpoint = "true"
#   })
# }

# module "vpc_endpoints_nocreate" {
#   source = "../../modules/vpc-endpoints"

#   create = false
# }

################################################################################
# Supporting Resources
################################################################################

# data "aws_iam_policy_document" "generic_endpoint_policy" {
#   statement {
#     effect    = "Deny"
#     actions   = ["*"]
#     resources = ["*"]

#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     condition {
#       test     = "StringNotEquals"
#       variable = "aws:SourceVpc"

#       values = [module.vpc.vpc_id]
#     }
#   }
# }
