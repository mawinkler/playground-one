# #############################################################################
# RDS MySQL
# #############################################################################
resource "aws_db_instance" "database-instance" {
  identifier             = "${var.environment}-db-${random_string.suffix.result}"
  allocated_storage      = 10
  instance_class         = "db.t3.micro"
  engine                 = "mysql"
  engine_version         = "5.7"
  username               = "root"
  password               = "T2kVB3zgeN3YbrKS"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  availability_zone      = "${var.aws_region}a"
  db_subnet_group_name   = var.database_subnet_group
  vpc_security_group_ids = [aws_security_group.database-security-group.id]
}

resource "aws_secretsmanager_secret" "rds_creds" {
  name                    = "RDS_CREDS"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_creds.id
  secret_string = <<EOF
   {
    "username": "root",
    "password": "T2kVB3zgeN3YbrKS"
   }
EOF
}

resource "null_resource" "rds_endpoint" {
  provisioner "local-exec" {
    command     = <<EOF
RDS_URL="${aws_db_instance.database-instance.endpoint}"
RDS_URL=$${RDS_URL::-5}
sed -i "s,RDS_ENDPOINT_VALUE,$RDS_URL,g" ${path.module}/resources/ecs/task_definition.json
EOF
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    aws_db_instance.database-instance
  ]
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command     = <<EOF
RDS_URL="${aws_db_instance.database-instance.endpoint}"
RDS_URL=$${RDS_URL::-5}
sed -i "s,$RDS_URL,RDS_ENDPOINT_VALUE,g" ${path.module}/resources/ecs/task_definition.json
EOF
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    null_resource.rds_endpoint, aws_ecs_task_definition.task_definition
  ]
}
