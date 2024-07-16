# #############################################################################
# Locals
# #############################################################################
locals {
  userdata_linux_db = templatefile("${path.module}/userdata_linux.tftpl", {
    s3_bucket      = var.s3_bucket
    linux_hostname = var.linux_db_hostname
  })

  userdata_linux_web = templatefile("${path.module}/userdata_linux.tftpl", {
    s3_bucket      = var.s3_bucket
    linux_hostname = var.linux_web_hostname
  })

  userdata_windows = templatefile("${path.module}/userdata_windows.tftpl", {
    windows_username = var.windows_username
    windows_hostname = var.windows_hostname
    windows_password = random_password.windows_password.result
    public_key       = var.public_key

    windows_ad_domain_name   = var.windows_ad_domain_name
    windows_ad_user_name     = var.windows_ad_user_name
    windows_ad_safe_password = var.windows_ad_safe_password
  })
}
