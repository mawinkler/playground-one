# #############################################################################
# Locals
# #############################################################################
locals {
    userdata_linux = templatefile("${path.module}/userdata_linux.tftpl", {
        s3_bucket = var.s3_bucket
    })

    userdata_windows = templatefile("${path.module}/userdata_windows.tftpl", {
        windows_username = var.windows_username
        windows_password = random_password.windows_password.result
        public_key = var.public_key
    })
}
