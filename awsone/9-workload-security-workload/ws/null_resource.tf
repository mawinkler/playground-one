# ####################################
# Deep Security Systemsettings API
# ####################################
resource "null_resource" "always_run" {
  triggers = {
    timestamp = "${timestamp()}"
  }
}
