# ####################################
# Kubernetes Configuration
# ####################################
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

terraform {
  required_version = "~> 1.6"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}
