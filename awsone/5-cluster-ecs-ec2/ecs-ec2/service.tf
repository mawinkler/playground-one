################################################################################
# Service
################################################################################
module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.11.2"

  # Service
  name        = module.ecs.cluster_name
  cluster_arn = module.ecs.cluster_arn

  # Task Definition
  requires_compatibilities = ["EC2"]
  capacity_provider_strategy = {
    # Spot instances
    asg-spot = {
      capacity_provider = module.ecs.autoscaling_capacity_providers["asg-spot"].name
      weight            = 2
      base              = 0
    }
    # On-demand instances currently disabled
    # See ecs-ec2.tf and autoscaler.tf to reenable
    #
    # # On-demand instances
    # asg-ondemand = {
    #   capacity_provider = module.ecs.autoscaling_capacity_providers["asg-ondemand"].name
    #   weight            = 1
    #   base              = 1
    # }
  }

  volume = {
    my-vol = {}
  }

  container_definitions = {
    (local.container_name) = {
      image = "mawinkler/goof:latest"
      port_mappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          protocol      = "tcp"
        }
      ]
      readonly_root_filesystem = false
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["http"].arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = var.private_subnets
  security_group_rules = {
    alb_http_ingress = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb_sg.security_group_id
    }
  }

  tags = {
    Name          = "${var.environment}-ecs-ec2-service"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ecs-ec2"
  }
}
