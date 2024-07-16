# #############################################################################
# Locals
# #############################################################################
locals {
  userdata_linux_pap = templatefile("${path.module}/userdata_linux.tftpl", {
    s3_bucket      = var.s3_bucket
    linux_hostname = var.linux_pap_hostname
  })
}
