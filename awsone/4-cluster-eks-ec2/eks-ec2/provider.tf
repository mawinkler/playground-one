# #############################################################################
# Provider
# #############################################################################
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
    # token                  = data.aws_eks_cluster_auth.eks.token
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      # args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.id]
      args        = ["eks", "get-token", "--cluster-name", "${module.eks.cluster_name}"]
      command     = "aws"
    }
  }
}
