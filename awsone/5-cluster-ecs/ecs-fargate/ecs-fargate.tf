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
    #     weight = 50
    #     base   = 20
    #   }
    # }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = {
    Name        = "${var.environment}-ecs-fargate"
    Environment = "${var.environment}"
  }
}
