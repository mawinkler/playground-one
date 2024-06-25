################################################################################
# Service
################################################################################
module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.11.2"

  # Service
  name        = module.ecs.cluster_name
  cluster_arn = module.ecs.cluster_arn

  cpu    = 1024
  memory = 4096

  volume = {
    my-vol = {}
  }

  # Container definition(s)
  # container_definitions = {
  #   (local.container_name) = {
  #     image = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
  #     port_mappings = [
  #       {
  #         name          = local.container_name
  #         containerPort = local.container_port
  #         protocol      = "tcp"
  #       }
  #     ]

  #     mount_points = [
  #       {
  #         sourceVolume  = "my-vol",
  #         containerPath = "/var/www/my-vol"
  #       }
  #     ]

  #     entry_point = ["/usr/sbin/apache2", "-D", "FOREGROUND"]

  #     # Example image used requires access to write to root filesystem
  #     readonly_root_filesystem = false
  #   }
  # }

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

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = {
      client_alias = {
        port     = local.container_port
        dns_name = local.container_name
      }
      port_name      = local.container_name
      discovery_name = local.container_name
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
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name          = "${var.environment}-ecs-fargate-service"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ecs-fg"
  }
}

resource "aws_service_discovery_http_namespace" "this" {
  name        = module.ecs.cluster_name
  description = "CloudMap namespace for ${module.ecs.cluster_name}"

  tags = {
    Name          = "${var.environment}-ecs-fargate-service-discovery-namespace"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ecs-fg"
  }
}
