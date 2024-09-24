locals {
  deepsecurity_version = "20.0"
  #   agent = "Agent-Ubuntu_20.04-20.0.0-8268.x86_64.zip"
  agent = "Agent-amzn2-20.0.0-8268.x86_64.zip"

  userdata_amzn = templatefile("${path.module}/userdata_amzn.tftpl", {
    s3_bucket           = var.s3_bucket
    linux_username_amzn = var.linux_username_amzn
    linux_policy_id     = var.linux_policy_id
  })

  userdata_deb = templatefile("${path.module}/userdata_deb.tftpl", {
    s3_bucket           = var.s3_bucket
    linux_username_ubnt = var.linux_username_ubnt
    linux_policy_id     = var.linux_policy_id
  })

  userdata_rhel = templatefile("${path.module}/userdata_rhel.tftpl", {
    s3_bucket           = var.s3_bucket
    linux_username_rhel = var.linux_username_rhel
    linux_policy_id     = var.linux_policy_id
  })

  userdata_windows = templatefile("${path.module}/userdata_windows.tftpl", {
    s3_bucket         = var.s3_bucket
    windows_username  = var.windows_username
    windows_password  = random_password.windows_password.result
    windows_policy_id = var.windows_policy_id
    public_key        = var.public_key
  })

  linux_amzn2_count  = 1
  linux_ubuntu_count = 1
  linux_rhel_count   = 0
  windows_count      = 1
}
