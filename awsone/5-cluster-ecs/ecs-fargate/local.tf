locals {
  # container_name = "ecs-sample"
  # container_port = 80
  container_name     = "goof"
  container_port     = 8080
  load_balancer_port = 80

  # tags = {
  #   Name        = "${var.environment}-ecs-fargate"
  #   Environment = "${var.environment}"
  # }
}
