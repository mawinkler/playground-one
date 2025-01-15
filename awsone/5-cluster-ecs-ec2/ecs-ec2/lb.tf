################################################################################
# Create Application Load Balancer
################################################################################
# Issues:
# https://github.com/eksctl-io/eksctl/issues/7987

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.2"

  name        = "${module.ecs.cluster_name}-service"
  description = "Service security group"
  vpc_id      = var.vpc_id

  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = var.access_ip

  egress_rules       = ["all-all"]
  egress_cidr_blocks = var.private_subnet_cidr_blocks

  tags = {
    Name          = "${var.environment}-ecs-ec2-alb-security-group"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ecs-ec2"
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.9.0"

  name = module.ecs.cluster_name

  load_balancer_type = "application"

  vpc_id                     = var.vpc_id
  subnets                    = var.public_subnets
  security_groups            = [module.alb_sg.security_group_id]
  enable_deletion_protection = false

  listeners = {
    http = {
      port     = local.load_balancer_port
      protocol = "HTTP"
      forward = {
        target_group_key = "http"
      }
    }
  }

  target_groups = {
    http = {
      name              = "${module.ecs.cluster_name}-${local.container_name}"
      backend_protocol  = "HTTP"
      backend_port      = local.container_port
      target_type       = "ip"
      create_attachment = false
    }
  }

  tags = {
    Name          = "${var.environment}-ecs-ec2-alb"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ecs-ec2"
  }
}
