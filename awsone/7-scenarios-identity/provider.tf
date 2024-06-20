# #############################################################################
# Providers
# #############################################################################
provider "aws" {
  region  = var.aws_region
  # profile = "default"
}

terraform {
  required_version = ">= 1.6"
}

provider "ad" {
  winrm_hostname = data.terraform_remote_state.vpc.outputs.ad_dc_ip
  winrm_username = "Administrator"
  winrm_password = data.terraform_remote_state.vpc.outputs.ad_admin_password
  winrm_use_ntlm = true
  winrm_port     = 5986
  winrm_proto    = "https"
  winrm_insecure = true
}

# provider "ad" {
#   winrm_hostname = module.mad[0].mad_ips[0]
#   winrm_username = "Administrator"
#   winrm_password = module.mad[0].mad_admin_password
#   # winrm_use_ntlm = true
#   # winrm_port     = 5986
#   # winrm_proto    = "https"
#   winrm_insecure = true
# }
