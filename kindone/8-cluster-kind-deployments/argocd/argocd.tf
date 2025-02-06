# #############################################################################
# Deploy ArgoCD
# #############################################################################

# resource "random_password" "password" {
#   length  = 16
#   special = false  # Set to true if you want special characters
# }

# Hash the password using bcrypt
resource "terraform_data" "admin_secret_bcrypt_hash" {
  # input = bcrypt(random_password.password.result)
  input = bcrypt(var.admin_secret)
}

# # Create a Kubernetes Opaque Secret
# resource "kubernetes_secret" "argocd-admin-secret" {
#   metadata {
#     name      = "argocd-admin-secret"
#     namespace = var.namespace
#   }

#   data = {
#     # password = base64encode(terraform_data.bcrypt_hash.output)  # Encode bcrypt hash in base64
#     password = terraform_data.bcrypt_hash.output  # Encode bcrypt hash
#   }

#   type = "Opaque"
# }

resource "helm_release" "argocd" {
  depends_on = [terraform_data.admin_secret_bcrypt_hash]

  name       = "argocd"
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.3" # Use latest stable version

  set {
    name  = "configs.params.server.insecure"
    value = true
  }

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = terraform_data.admin_secret_bcrypt_hash.output
  }

  set {
    name  = "server.service.type"
    value = "LoadBalancer" # Change to ClusterIP if using an Ingress
  }
}
