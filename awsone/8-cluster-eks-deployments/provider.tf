# ####################################
# Kubernetes Configuration
# ####################################
provider "aws" {
  region = var.aws_region
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  profile = "default"
}

data "aws_eks_cluster" "eks" {
  # name = "${var.environment}-eks"
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  # name = "${var.environment}-eks"
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.id]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      # args        = ["eks", "get-token", "--cluster-name", "${var.environment}-eks"]
      args        = ["eks", "get-token", "--cluster-name", "${data.terraform_remote_state.eks.outputs.cluster_name}"]
      command     = "aws"
    }
  }
}

# ####################################
# Container Security API Configuration
# ####################################
terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.18.0"
    }
  }
  required_version = ">= 1.3.5"
}

provider "restapi" {
  alias                = "clusters"
  uri                  = "https://container.${var.cloud_one_region}.${var.cloud_one_instance}.trendmicro.com/api/clusters"
  debug                = true
  write_returns_object = true

  headers = {
    Authorization = "ApiKey ${var.api_key}"
    Content-Type  = "application/json"
    api-version   = "v1"
  }
}