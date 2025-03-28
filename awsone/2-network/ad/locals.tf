# #############################################################################
# Locals
# #############################################################################
locals {
  # Windows Userdata Functions
  userdata_function_windows_winrm = templatefile("${path.module}/userdata_function_windows_winrm.tftpl", {
  })

  userdata_function_windows_ssh = templatefile("${path.module}/userdata_function_windows_ssh.tftpl", {
    windows_username = var.windows_username
    public_key       = var.public_key
  })

  userdata_function_windows_aws = templatefile("${path.module}/userdata_function_windows_aws.tftpl", {
  })

  userdata_function_windows_join_ad = templatefile("${path.module}/userdata_function_windows_join_ad.tftpl", {
    windows_ad_domain_name   = var.windows_ad_domain_name
    windows_ad_user_name     = var.windows_ad_user_name
    windows_ad_safe_password = var.windows_ad_safe_password
  })

  # Windows Userdata
  userdata_dc = templatefile("${path.module}/userdata_dc.tftpl", {
    windows_ad_safe_password = var.windows_ad_safe_password
    windows_ad_domain_name   = var.windows_ad_domain_name
    windows_ad_nebios_name   = var.windows_ad_nebios_name
    windows_ad_hostname      = "PGO-DC"

    userdata_windows_winrm = local.userdata_function_windows_winrm
    userdata_windows_ssh   = local.userdata_function_windows_ssh
    userdata_windows_aws   = local.userdata_function_windows_aws
  })

  userdata_ca = templatefile("${path.module}/userdata_ca.tftpl", {
    windows_ad_safe_password = var.windows_ad_safe_password
    windows_ad_domain_name   = var.windows_ad_domain_name
    windows_ad_user_name     = var.windows_ad_user_name
    windows_ad_hostname      = "PGO-CA"

    userdata_windows_winrm   = local.userdata_function_windows_winrm
    userdata_windows_ssh     = local.userdata_function_windows_ssh
    userdata_windows_aws     = local.userdata_function_windows_aws
    userdata_windows_join_ad = local.userdata_function_windows_join_ad
  })
}
