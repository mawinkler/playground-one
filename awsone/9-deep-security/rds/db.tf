################################################################################
# RDS Database
################################################################################
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "random_string" "rds_password" {
  length  = 14
  lower   = true
  upper   = true
  numeric = true
  special = false
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.2.0"

  identifier = "${var.environment}-rds-${random_string.suffix.result}"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.m5.large"

  allocated_storage     = 20
  max_allocated_storage = 100
  skip_final_snapshot   = true

  manage_master_user_password = false
  db_name                     = var.rds_name
  username                    = var.rds_username
  password                    = random_string.rds_password.result
  port                        = 5432

  multi_az               = false
  db_subnet_group_name   = var.database_subnet_group
  vpc_security_group_ids = [var.private_security_group_id]
  deletion_protection    = false

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  tags = {
    Name          = "${var.environment}-rds"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "dsm"
  }

  db_option_group_tags = {
    "Sensitive" = "low"
  }

  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
}
