# ####################################
# Kubernetes Configuration
# ####################################
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.aks.outputs.kube_config.0.host
  username               = data.terraform_remote_state.aks.outputs.kube_config.0.username
  password               = data.terraform_remote_state.aks.outputs.kube_config.0.password
  client_certificate     = base64decode(data.terraform_remote_state.aks.outputs.kube_config.0.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.aks.outputs.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.aks.outputs.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.aks.outputs.kube_config.0.host
    username               = data.terraform_remote_state.aks.outputs.kube_config.0.username
    password               = data.terraform_remote_state.aks.outputs.kube_config.0.password
    client_certificate     = base64decode(data.terraform_remote_state.aks.outputs.kube_config.0.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.aks.outputs.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.aks.outputs.kube_config.0.cluster_ca_certificate)
  }
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
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.20"
    }
    visionone = {
      source  = "trendmicro/vision-one"
      version = "~> 1.0"
    }
  }
}
