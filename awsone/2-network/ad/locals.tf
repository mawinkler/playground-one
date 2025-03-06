locals {
  # Windows Userdata Functions
  userdata_function_windows_winrm = templatefile("${path.module}/userdata_function_windows_winrm.tftpl", {
  })

  userdata_function_windows_aws = templatefile("${path.module}/userdata_function_windows_aws.tftpl", {
  })

  # Windows Userdata
  userdata_dc = templatefile("${path.module}/userdata_dc.tftpl", {
    windows_ad_safe_password = var.windows_ad_safe_password
    windows_ad_domain_name   = var.windows_ad_domain_name
    windows_ad_nebios_name   = var.windows_ad_nebios_name
    windows_ad_hostname      = "PGO-DC"

    userdata_windows_winrm   = local.userdata_function_windows_winrm
    userdata_windows_aws     = local.userdata_function_windows_aws
  })

  userdata_ca = templatefile("${path.module}/userdata_ca.tftpl", {
    windows_ad_safe_password = var.windows_ad_safe_password
    windows_ad_domain_name   = var.windows_ad_domain_name
    windows_ad_user_name     = var.windows_ad_user_name
    windows_ad_hostname      = "PGO-CA"
  })
}
