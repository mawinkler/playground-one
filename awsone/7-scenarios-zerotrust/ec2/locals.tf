# #############################################################################
# Locals
# #############################################################################
locals {
  userdata_linux = templatefile("${path.module}/userdata_linux.tftpl", {
    s3_bucket      = var.s3_bucket
    linux_hostname = var.linux_hostname
  })

  userdata_windows = [
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_username         = var.windows_username
      windows_password         = random_password.windows_password.result
      windows_ad_hostname      = "Server-0"
      windows_ad_join          = false
      s3_bucket                = var.s3_bucket
    }),
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_username         = var.windows_username
      windows_password         = random_password.windows_password.result
      windows_ad_hostname      = "Member-1"
      windows_ad_join          = true
      s3_bucket                = var.s3_bucket
    }),
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_username         = var.windows_username
      windows_password         = random_password.windows_password.result
      windows_ad_hostname      = "Member-2"
      windows_ad_join          = true
      s3_bucket                = var.s3_bucket
    }),
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_username         = var.windows_username
      windows_password         = random_password.windows_password.result
      windows_ad_hostname      = "Member-3"
      windows_ad_join          = true
      s3_bucket                = var.s3_bucket
    }),
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_username         = var.windows_username
      windows_password         = random_password.windows_password.result
      windows_ad_hostname      = "Member-4"
      windows_ad_join          = true
      s3_bucket                = var.s3_bucket
    }),
    templatefile("${path.module}/userdata_windows.tftpl", {
      windows_ad_safe_password = var.windows_ad_safe_password
      windows_ad_domain_name   = var.windows_ad_domain_name
      windows_ad_user_name     = var.windows_ad_user_name
      windows_username         = var.windows_username
      windows_password         = random_password.windows_password.result
      windows_ad_hostname      = "Member-5"
      windows_ad_join          = true
      s3_bucket                = var.s3_bucket
    })
  ]
}
