# #############################################################################
# Keypair for SSH instance access
# #############################################################################
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.environment}-key-pair-${random_string.suffix.result}"
  public_key = tls_private_key.key_pair.public_key_openssh

  tags = {
    Name          = "${var.environment}-key-pair-${random_string.suffix.result}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}

# Save file
resource "local_file" "ssh_key" {
  filename        = "uploads/server.pem"
  content         = tls_private_key.key_pair.private_key_pem
  file_permission = "0600"
}
