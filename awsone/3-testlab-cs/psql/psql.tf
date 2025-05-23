resource "random_string" "psql_password" {
  length  = 14
  lower   = true
  upper   = true
  numeric = true
  special = false
}

resource "aws_network_interface" "postgres_eni" {
  subnet_id       = var.private_subnets[0]
  private_ips     = [var.postgresql_private_ip]
  security_groups = [var.private_security_group_id]
}

resource "aws_instance" "postgres" {
  ami                  = var.ami_postgresql != "" ? var.ami_postgresql : data.aws_ami.ubuntu.id
  instance_type        = "t3.medium"
  iam_instance_profile = var.ec2_profile
  key_name             = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              if which psql > /dev/null 2>&1; then
                echo "PostgreSQL is installed"
                touch postgresql_no_init
              else
                echo "PostgreSQL is NOT installed"
                apt update && apt install -y postgresql postgresql-contrib
                sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${var.psql_password}';"
                sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/14/main/postgresql.conf
                echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/14/main/pg_hba.conf
                systemctl restart postgresql
              fi
              EOF

  network_interface {
    network_interface_id = aws_network_interface.postgres_eni.id
    device_index         = 0 # Primary network interface
  }

  tags = {
    Name          = "${var.environment}-postgresql"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "testlab-cs"
  }

  connection {
    user             = "ubuntu"
    host             = self.private_ip
    private_key      = file("${var.private_key_path}")
  }

  provisioner "remote-exec" {
    inline = [
      "if [ ! -f postgresql_no_init ]; then",
      "  sleep 60",
      "  sudo -u postgres -i -- psql --command=\"CREATE DATABASE \\\"${var.psql_name}\\\";\"",
      "  sudo -u postgres -i -- psql --command=\"CREATE ROLE \\\"${var.psql_username}\\\" WITH PASSWORD '${random_string.psql_password.result}' LOGIN;\"",
      "  sudo -u postgres -i -- psql --command=\"GRANT ALL ON DATABASE \\\"${var.psql_name}\\\" TO \\\"${var.psql_username}\\\";\"",
      "  sudo -u postgres -i -- psql --command=\"GRANT CONNECT ON DATABASE \"${var.psql_name}\" TO \\\"${var.psql_username}\\\";\"",
      "  sudo -u postgres -i -- psql --command=\"ALTER DATABASE \\\"${var.psql_name}\\\" OWNER TO \\\"${var.psql_username}\\\";\"",
      "else",
      "  echo 'Reusing existing database.'",
      "fi"
    ]
  }
}
