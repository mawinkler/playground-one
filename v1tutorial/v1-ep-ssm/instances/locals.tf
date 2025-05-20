# #############################################################################
# Locals
# #############################################################################
locals {
  # Windows Userdata Functions
  userdata_function_windows_winrm = templatefile("${path.module}/templates/userdata_function_windows_winrm.tftpl", {
  })

  userdata_function_windows_ssh = templatefile("${path.module}/templates/userdata_function_windows_ssh.tftpl", {
    windows_username = var.windows_username
    public_key       = var.public_key
  })

  userdata_function_windows_aws = templatefile("${path.module}/templates/userdata_function_windows_aws.tftpl", {
  })

  # Linux Userdata
  userdata_linux = templatefile("${path.module}/templates/userdata_linux.tftpl", {
    s3_bucket      = var.s3_bucket
    linux_hostname = var.linux_hostname
    tm_agent       = var.agent_variant
  })
}
