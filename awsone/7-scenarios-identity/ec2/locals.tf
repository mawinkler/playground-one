# #############################################################################
# Locals
# #############################################################################
locals {
  userdata_windows = templatefile("${path.module}/userdata_windows.tftpl", {
    windows_ad_safe_password = var.windows_ad_safe_password
    windows_ad_domain_name   = var.windows_ad_domain_name
    windows_ad_user_name     = var.windows_ad_user_name
  })
}
