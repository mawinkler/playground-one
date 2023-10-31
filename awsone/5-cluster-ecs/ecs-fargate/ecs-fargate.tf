# #############################################################################
# ECS Cluster
# #############################################################################
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.2.0"

  cluster_name = "${var.environment}-ecs-${random_string.suffix.result}"

  fargate_capacity_providers = {
    # On-demand instances currently disabled
    #
    # FARGATE = {
    #   default_capacity_provider_strategy = {
    #     weight = 1
    #     base   = 2
    #   }
    # }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 2
      }
    }
    # Weight setting means that for each Fargate task (weight=1)
    # it will place 2 Fargate Spot tasks (weight=2), however
    # specifying the base as well has a higher priority and 
    # enforces having at least 2 Fargate tasks before launching 
    # any Fargate Spot tasks. Any additional tasks on top of the 
    # base number would be split between Fargate and Fargate-Spot 
    # in 1:2 ratio. In this example we will have 2 Fargate and 
    # 1 Fargate-Spot tasks.
  }

  tags = {
    Name        = "${var.environment}-ecs-fargate"
    Environment = "${var.environment}"
  }
}
