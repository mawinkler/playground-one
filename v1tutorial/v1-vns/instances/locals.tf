# #############################################################################
# Locals
# #############################################################################
locals {
  userdata_function_windows_winrm = templatefile("${path.module}/userdata_function_windows_winrm.tftpl", {
  })

  userdata_function_windows_ssh = templatefile("${path.module}/userdata_function_windows_ssh.tftpl", {
    windows_username = var.windows_username
    public_key       = var.public_key
  })

  userdata_function_windows_aws = templatefile("${path.module}/userdata_function_windows_aws.tftpl", {
  })

  userdata_linux = templatefile("${path.module}/userdata_linux.tftpl", {
    linux_hostname = var.linux_hostname
  })
}
