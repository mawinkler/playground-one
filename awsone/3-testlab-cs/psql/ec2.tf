resource "random_string" "psql_password" {
  length  = 14
  lower   = true
  upper   = true
  numeric = true
  special = false
}

resource "aws_instance" "postgres" {
  ami                  = data.aws_ami.ubuntu.id
  subnet_id            = var.private_subnets[0]
  instance_type        = "t3.medium"
  iam_instance_profile = var.ec2_profile
  key_name             = var.key_name
  security_groups      = [var.private_security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              apt update && apt install -y postgresql postgresql-contrib
              sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${var.psql_password}';"
              sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/14/main/postgresql.conf
              echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/14/main/pg_hba.conf
              systemctl restart postgresql
              EOF

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
    bastion_host     = var.bastion_public_ip
    bastion_user     = "ubuntu"
    bastion_host_key = var.public_key
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 60",
      "sudo -u postgres -i -- psql --command=\"CREATE DATABASE \\\"${var.psql_name}\\\";\"",
      "sudo -u postgres -i -- psql --command=\"CREATE ROLE \\\"${var.psql_username}\\\" WITH PASSWORD '${random_string.psql_password.result}' LOGIN;\"",
      "sudo -u postgres -i -- psql --command=\"GRANT ALL ON DATABASE \\\"${var.psql_name}\\\" TO \\\"${var.psql_username}\\\";\"",
      "sudo -u postgres -i -- psql --command=\"GRANT CONNECT ON DATABASE \"${var.psql_name}\" TO \\\"${var.psql_username}\\\";\"",
      "sudo -u postgres -i -- psql --command=\"ALTER DATABASE \\\"${var.psql_name}\\\" OWNER TO \\\"${var.psql_username}\\\";\""
    ]
  }
}
