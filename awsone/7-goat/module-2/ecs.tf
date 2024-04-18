# #############################################################################
# ECS Cluster
# #############################################################################
resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = data.aws_ami.ecs_optimized_ami.id
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.name
  security_groups      = [aws_security_group.ecs_sg.id]
  user_data            = data.template_file.user_data.rendered
  instance_type        = "t3.medium"
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "ECS-lab-asg"
  vpc_zone_identifier  = var.public_subnets
  launch_configuration = aws_launch_configuration.ecs_launch_config.name
  desired_capacity     = 1
  min_size             = 0
  max_size             = 1
}

resource "aws_ecs_cluster" "cluster" {
  name = "ecs-lab-cluster"

  tags = {
    name = "ecs-cluster-name"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  container_definitions    = data.template_file.task_definition_json.rendered
  family                   = "ECS-Lab-Task-definition"
  network_mode             = "bridge"
  memory                   = "2048"
  cpu                      = "512"
  requires_compatibilities = ["EC2"]
  task_role_arn            = aws_iam_role.ecs-task-role.arn

  pid_mode = "host"
  volume {
    name      = "modules"
    host_path = "/lib/modules"
  }
  volume {
    name      = "kernels"
    host_path = "/usr/src/kernels"
  }
}

resource "aws_ecs_service" "worker" {
  name                              = "ecs_service_worker"
  cluster                           = aws_ecs_cluster.cluster.id
  task_definition                   = aws_ecs_task_definition.task_definition.arn
  desired_count                     = 1
  health_check_grace_period_seconds = 2147483647

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "aws-goat-m2"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.listener]
}
