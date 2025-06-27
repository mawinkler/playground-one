# #############################################################################
# Secrets
# #############################################################################
resource "kubernetes_secret" "trendmicro-container-security-registration-key" {
  metadata {
    name      = "trendmicro-container-security-registration-key"
    namespace = var.namespace
  }

  data = {
    "registration.key" = var.registration_key
  }

  type = "Opaque"
}
