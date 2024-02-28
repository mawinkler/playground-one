# ####################################
# Kubernetes Configuration
# ####################################
# provider "kubectl" {
#   host                   = data.terraform_remote_state.kind.outputs.kube_config.clusters.0.cluster.server
#   client_certificate     = base64decode(data.terraform_remote_state.kind.outputs.kube_config.users.0.user.client-certificate-data)
#   client_key             = base64decode(data.terraform_remote_state.kind.outputs.kube_config.users.0.user.client-key-data)
#   cluster_ca_certificate = base64decode(data.terraform_remote_state.kind.outputs.kube_config.clusters.0.cluster.certificate-authority-data)
#   load_config_file       = false
# }

# ####################################
# Container Security API Configuration
# ####################################
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
  required_version = ">= 1.6"
}
