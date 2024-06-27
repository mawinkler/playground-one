# #############################################################################
# Locals
# #############################################################################
locals {
  userdata_windows = [
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_ad_hostname      = "Member-0"
    }),
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_ad_hostname      = "Member-1"
    }),
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_ad_hostname      = "Member-2"
    }),
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_ad_hostname      = "Member-3"
    }),
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_ad_hostname      = "Member-4"
    }),
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_ad_hostname      = "Member-5"
    })
  ]
}
