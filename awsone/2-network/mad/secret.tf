# #############################################################################
# MAD admin secret
# #############################################################################
resource "random_password" "mad_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "aws_secretsmanager_secret" "mad_admin_secret" {
  name = "${var.environment}-mad.local-${local.ds_managed_ad_admin_secret_sufix}-${random_string.suffix.result}"
  #   kms_key_id = var.ds_managed_ad_secret_key
  recovery_window_in_days = 30
}

resource "aws_secretsmanager_secret_version" "mad_admin_secret_version" {
  secret_id     = aws_secretsmanager_secret.mad_admin_secret.id
  secret_string = random_password.mad_admin_password.result
}
