# #############################################################################
# Locals
# #############################################################################
locals {
  userdata_apex_one_server = templatefile("${path.module}/userdata_apex_one_server.tftpl", {
    s3_bucket        = var.s3_bucket
    windows_username = var.windows_username
    windows_hostname = "Apex-One-Server"
    windows_password = random_password.windows_password.result
    public_key       = var.public_key

    windows_ad_domain_name   = var.active_directory ? var.windows_ad_domain_name : ""
    windows_ad_user_name     = var.windows_ad_user_name
    windows_ad_safe_password = var.windows_ad_safe_password
  })

  userdata_apex_one_central = templatefile("${path.module}/userdata_apex_one_central.tftpl", {
    s3_bucket        = var.s3_bucket
    windows_username = var.windows_username
    windows_hostname = "Apex-One-Central"
    windows_password = random_password.windows_password.result
    public_key       = var.public_key

    windows_ad_domain_name   = var.active_directory ? var.windows_ad_domain_name : ""
    windows_ad_user_name     = var.windows_ad_user_name
    windows_ad_safe_password = var.windows_ad_safe_password
  })
}
