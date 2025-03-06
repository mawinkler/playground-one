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
    windows_ad_domain_name   = var.active_directory ? var.windows_ad_domain_name : ""
    windows_ad_user_name     = var.windows_ad_user_name
    windows_ad_safe_password = var.windows_ad_safe_password
  })

  # Linux Userdata
  userdata_linux_db = templatefile("${path.module}/userdata_linux.tftpl", {
    s3_bucket      = var.s3_bucket
    linux_hostname = var.linux_db_hostname
    tm_agent       = var.agent_variant
  })

  userdata_linux_web = templatefile("${path.module}/userdata_linux.tftpl", {
    s3_bucket      = var.s3_bucket
    linux_hostname = var.linux_web_hostname
    tm_agent       = var.agent_variant
  })

  # Windows Userdata
  userdata_windows = templatefile("${path.module}/userdata_windows.tftpl", {
    s3_bucket        = var.s3_bucket
    windows_username = var.windows_username
    windows_hostname = var.windows_hostname
    windows_password = random_password.windows_password.result

    userdata_windows_winrm   = local.userdata_function_windows_winrm
    userdata_windows_ssh     = local.userdata_function_windows_ssh
    userdata_windows_aws     = local.userdata_function_windows_aws
    userdata_windows_join_ad = local.userdata_function_windows_join_ad

    windows_ad_domain_name   = var.active_directory ? var.windows_ad_domain_name : ""
    windows_ad_user_name     = var.windows_ad_user_name
    windows_ad_safe_password = var.windows_ad_safe_password
    tm_agent                 = var.agent_variant
  })
}
