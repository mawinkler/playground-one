# #############################################################################
# Data
# #############################################################################
data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-kernel-5.10-hvm-2.0.*-x86_64-ebs"]
  }
}

data "template_file" "user_data" {
  template = local.userdata_linux
}

data "template_file" "task_definition_json" {
  template = file("${path.module}/resources/ecs/task_definition.json")
  depends_on = [
    null_resource.rds_endpoint
  ]
}
