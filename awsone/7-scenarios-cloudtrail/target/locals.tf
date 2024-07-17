# #############################################################################
# Locals
# #############################################################################
locals {
  userdata_linux_pap = templatefile("${path.module}/userdata_linux.tftpl", {
    linux_hostname = var.linux_hostname
  })
}
