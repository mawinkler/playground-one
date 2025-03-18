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

  # Windows Userdata
  userdata_apex_one_server = templatefile("${path.module}/userdata_apex_one_server.tftpl", {
    s3_bucket              = var.s3_bucket
    windows_username       = var.windows_username
    windows_hostname       = "Apex-One-Server"
    windows_password       = random_password.windows_password.result
    windows_ad_domain_name = var.active_directory ? var.windows_ad_domain_name : ""

    userdata_windows_winrm   = local.userdata_function_windows_winrm
    userdata_windows_ssh     = local.userdata_function_windows_ssh
    userdata_windows_aws     = local.userdata_function_windows_aws
    userdata_windows_join_ad = local.userdata_function_windows_join_ad
  })

  userdata_apex_one_central = templatefile("${path.module}/userdata_apex_one_central.tftpl", {
    s3_bucket              = var.s3_bucket
    windows_username       = var.windows_username
    windows_hostname       = "Apex-One-Central"
    windows_password       = random_password.windows_password.result
    windows_ad_domain_name = var.active_directory ? var.windows_ad_domain_name : ""

    userdata_windows_winrm   = local.userdata_function_windows_winrm
    userdata_windows_ssh     = local.userdata_function_windows_ssh
    userdata_windows_aws     = local.userdata_function_windows_aws
    userdata_windows_join_ad = local.userdata_function_windows_join_ad
  })

  userdata_windows_client = templatefile("${path.module}/userdata_windows_client.tftpl", {
    s3_bucket              = var.s3_bucket
    windows_ad_user_name       = var.windows_username
    windows_ad_hostname       = "Client"
    windows_ad_safe_password = var.windows_ad_safe_password

    # windows_password       = random_password.windows_password.result
    windows_ad_domain_name = var.active_directory ? var.windows_ad_domain_name : ""

    userdata_windows_winrm   = local.userdata_function_windows_winrm
    userdata_windows_ssh     = local.userdata_function_windows_ssh
    userdata_windows_aws     = local.userdata_function_windows_aws
    userdata_windows_join_ad = local.userdata_function_windows_join_ad
  })
}

output "userdata_windows_client" {
  value = local.userdata_windows_client
}
