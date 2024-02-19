# ####################################
# Kubernetes Configuration
# ####################################
provider "kubernetes" {
  host                   = data.terraform_remote_state.kind.outputs.kube_config.clusters.0.cluster.server
  client_certificate     = base64decode(data.terraform_remote_state.kind.outputs.kube_config.users.0.user.client-certificate-data)
  client_key             = base64decode(data.terraform_remote_state.kind.outputs.kube_config.users.0.user.client-key-data)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.kind.outputs.kube_config.clusters.0.cluster.certificate-authority-data)
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.kind.outputs.kube_config.clusters.0.cluster.server
    client_certificate     = base64decode(data.terraform_remote_state.kind.outputs.kube_config.users.0.user.client-certificate-data)
    client_key             = base64decode(data.terraform_remote_state.kind.outputs.kube_config.users.0.user.client-key-data)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.kind.outputs.kube_config.clusters.0.cluster.certificate-authority-data)
  }
  # experiments {
  #   manifest = true
  # }
}

# ####################################
# Container Security API Configuration
# ####################################
terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.18.2"
    }
  }
  required_version = ">= 1.6"
}

provider "restapi" {
  alias                = "container_security"
  uri                  = "https://api.xdr.trendmicro.com"
  debug                = true
  write_returns_object = true

  headers = {
    Authorization = "Bearer ${var.api_key}"
    Content-Type  = "application/json"
    api-version   = "v1"
  }
}
