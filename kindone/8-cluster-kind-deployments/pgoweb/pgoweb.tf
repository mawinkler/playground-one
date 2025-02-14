# #############################################################################
# Deploy the vulnerable web application pgoweb
# #############################################################################
resource "kubernetes_secret" "pgo_credentials" {
  depends_on = [kubernetes_namespace_v1.pgoweb_namespace]
  metadata {
    name      = "pgo-credentials"
    namespace = var.namespace
  }

  data = {
    AWS_ACCESS_KEY_ID     = var.aws_access_key
    AWS_SECRET_ACCESS_KEY = var.aws_secret_key
    V1_API_KEY            = var.api_key
  }

  type = "opaque"
}

resource "kubernetes_deployment_v1" "pgoweb_deployment" {
  depends_on = [kubernetes_namespace_v1.pgoweb_namespace, kubernetes_secret.pgo_credentials]
  metadata {
    name = "pgoweb"
    labels = {
      app = "pgoweb"
    }
    namespace = var.namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "pgoweb"
      }
    }
    strategy {
      rolling_update {
        max_surge       = "25%"
        max_unavailable = "25%"
      }
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          app = "pgoweb"
        }
      }
      spec {
        container {
          image             = "mawinkler/pgoweb"
          image_pull_policy = "Always"
          name              = "pgoweb"
          resources {
            limits = {
              cpu    = "50m"
              memory = "500Mi"
            }
          }
          port {
            container_port = 5000
          }
          env_from {
            secret_ref {
              name = "pgo-credentials"
            }
          }
        }
        restart_policy = "Always"
      }
    }
  }
}

# resource "kubernetes_deployment_v1" "pgoweb_deployment" {
#   depends_on = [kubernetes_namespace_v1.pgoweb_namespace]
#   metadata {
#     name = "pgoweb"
#     labels = {
#       app = "pgoweb"
#     }
#     namespace = var.namespace
#   }

#   spec {
#     replicas = 1
#     selector {
#       match_labels = {
#         app = "pgoweb"
#       }
#     }
#     strategy {
#       rolling_update {
#         max_surge       = "25%"
#         max_unavailable = "25%"
#       }
#       type = "RollingUpdate"
#     }
#     template {
#       metadata {
#         labels = {
#           app = "pgoweb"
#         }
#       }
#       spec {
#         container {
#           image             = "mawinkler/pgoweb"
#           image_pull_policy = "Always"
#           name              = "pgoweb"
#           resources {
#             limits = {
#               cpu    = "50m"
#               memory = "500Mi"
#             }
#           }
#           port {
#             container_port = 5000
#           }
#           env {
#             name  = "AWS_ACCESS_KEY_ID"
#             value = var.aws_access_key
#           }
#           env {
#             name  = "AWS_SECRET_ACCESS_KEY"
#             value = var.aws_secret_key
#           }
#           env {
#             name  = "V1_API_KEY"
#             value = var.api_key
#           }
#         }
#         restart_policy = "Always"
#       }
#     }
#   }
# }

resource "kubernetes_service_v1" "pgoweb_service" {
  depends_on = [kubernetes_namespace_v1.pgoweb_namespace]

  metadata {
    labels = {
      app = "pgoweb"
    }
    name      = "pgoweb-service"
    namespace = var.namespace
  }
  spec {
    # external_traffic_policy = "Cluster"
    # internal_traffic_policy = "Cluster"
    port {
      port        = 5000
      target_port = 5000
    }
    selector = {
      app = "pgoweb"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "pgoweb_ingress" {
  depends_on             = [kubernetes_namespace_v1.pgoweb_namespace]
  wait_for_load_balancer = true

  metadata {
    # annotations = {
    #   # "alb.ingress.kubernetes.io/scheme"        = "internet-facing"
    #   # "alb.ingress.kubernetes.io/target-type"   = "ip"
    #   # "kubernetes.io/ingress.class"             = "alb"
    #   # "alb.ingress.kubernetes.io/inbound-cidrs" = var.access_ip
    # }
    labels = {
      app = "pgoweb"
    }
    name      = "pgoweb-ingress"
    namespace = var.namespace
  }
  spec {
    default_backend {
      service {
        name = "pgoweb-service"
        port {
          number = 5000
        }
      }
    }
    # rule {
    #   http {
    #     path {
    #       backend {
    #         service {
    #           name = "pgoweb-service"
    #           port {
    #             number = 5000
    #           }
    #         }
    #       }
    #       path = "/*"
    #     }
    #   }
    # }
  }
}
