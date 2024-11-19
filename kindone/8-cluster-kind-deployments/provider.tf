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

provider "restapi" {
  alias                = "container_security"
  uri                  = var.api_url
  debug                = true
  write_returns_object = true

  headers = {
    Authorization = "Bearer ${var.api_key}"
    Content-Type  = "application/json"
    api-version   = "v1"
  }
}

provider "visionone" {
  alias         = "container_security"
  api_key       = var.api_key
  regional_fqdn = var.api_url
}

# ####################################
# Provider Configuration
# ####################################
terraform {
  required_version = ">= 1.6"

  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31.0"
    }
    random = { 
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.19.1"
    }
    visionone = {
      source  = "trendmicro/vision-one"
      version = "~> 1.0.4"
    }
  }
}
