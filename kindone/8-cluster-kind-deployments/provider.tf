# ####################################
# Kubernetes Configuration
# ####################################
provider "kubernetes" {
  host                   = data.terraform_remote_state.kind.outputs.kube_config.host
  username               = data.terraform_remote_state.kind.outputs.kube_config.username
  password               = data.terraform_remote_state.kind.outputs.kube_config.password
  client_certificate     = base64decode(data.terraform_remote_state.kind.outputs.kube_config.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.kind.outputs.kube_config.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.kind.outputs.kube_config.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.kind.outputs.kube_config.host
    username               = data.terraform_remote_state.kind.outputs.kube_config.username
    password               = data.terraform_remote_state.kind.outputs.kube_config.password
    client_certificate     = base64decode(data.terraform_remote_state.kind.outputs.kube_config.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.kind.outputs.kube_config.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.kind.outputs.kube_config.cluster_ca_certificate)
  }
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
