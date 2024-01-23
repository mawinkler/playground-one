# #############################################################################
# Deploy the vulnerable web application hunger-check
# #############################################################################
resource "kubernetes_role_v1" "hunger_check_role" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]

  metadata {
    name = "secret-reader"
    # labels = {
    #   app = "hunger-check"
    # }
    namespace = var.namespace
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["get", "watch", "list"]
  }
}

resource "kubernetes_role_binding_v1" "hunger_check_rolebinding" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]

  metadata {
    name = "secret-reader-binding"
    # labels = {
    #   app = "hunger-check"
    # }
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "secret-reader"
  }
  subject {
    kind = "ServiceAccount"
    name = "big-monolith-sa"
  }
}

resource "kubernetes_service_account_v1" "hunger_check_service_account" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]

  metadata {
    name = "big-monolith-sa"
    # labels = {
    #   app = "hunger-check"
    # }
    namespace = var.namespace
  }

}

resource "kubernetes_secret_v1" "hunger_check_vaultapikey" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]

  metadata {
    name = "vaultapikey"
    # labels = {
    #   app = "goatvault"
    # }
    namespace = var.namespace
  }
  binary_data = {
    k8svaultapikey = "azhzLWdvYXQtODUwNTc4NDZhODA0NmEyNWIzNWYzOGYzYTI2NDlkY2U="
  }
}

resource "kubernetes_secret_v1" "hunger_check_webhookapikey" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]

  metadata {
    name = "webhookapikey"
    # labels = {
    #   app = "goatvault"
    # }
    namespace = var.namespace
  }
  binary_data = {
    k8swebhookapikey = "azhzLWdvYXQtZGZjZjYzMDUzOTU1M2VjZjk1ODZmZGZkYTE5NjhmZWM="
  }
}

resource "kubernetes_deployment_v1" "hunger_check_deployment" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]

  metadata {
    name = "hunger-check"
    labels = {
      app = "hunger-check"
    }
    namespace = var.namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "hunger-check"
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
          app = "hunger-check"
        }
      }
      spec {
        service_account_name = "big-monolith-sa"
        container {
          image             = "madhuakula/k8s-goat-hunger-check"
          image_pull_policy = "Always"
          name              = "hunger-check"
          # resources {
          #   limits = {
          #     memory = "1000Gi"
          #   }
          #   requests = {
          #     memory = "1000Gi"
          #   }
          # }
          port {
            container_port = 8080
          }
          # command = ["stress-ng"]
          # args = ["--vm", "1", "--vm-bytes", "500M", "--vm-hang", "1", "-v"]
        }
        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service_v1" "hunger_check_service" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]

  metadata {
    labels = {
      app = "hunger-check"
    }
    name      = "hunger-check-service"
    namespace = var.namespace
  }
  spec {
    external_traffic_policy = "Cluster"
    internal_traffic_policy = "Cluster"
    port {
      port        = 8080
      target_port = 8080
    }
    selector = {
      app = "hunger-check"
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "hunger_check_ingress" {
  depends_on             = [kubernetes_namespace_v1.goat_namespace]
  wait_for_load_balancer = true

  metadata {
    annotations = {
      "kubernetes.io/ingress.class"             = "addon-http-application-routing"
      # "alb.ingress.kubernetes.io/inbound-cidrs" = var.access_ip
    }
    labels = {
      app = "hunger-check"
    }
    name      = "hunger-check-ingress"
    namespace = var.namespace
  }
  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "hunger-check-service"
              port {
                number = 8080
              }
            }
          }
          path = "/*"
        }
      }
    }
  }
}
