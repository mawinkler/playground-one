# #############################################################################
# Deploy the vulnerable web application system-monitor
# #############################################################################
resource "kubernetes_secret_v1" "goatvault" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]
  metadata {
    name = "goatvault"
    labels = {
      app = "goatvault"
    }
    namespace = var.namespace
  }
  binary_data = {
    k8sgoatvaultkey = "azhzLWdvYXQtY2QyZGEyNzIyNDU5MWRhMmI0OGVmODM4MjZhOGE2YzM="
  }
}

resource "kubernetes_deployment_v1" "system_monitor_deployment" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]
  metadata {
    name = "system-monitor"
    labels = {
      app = "system-monitor"
    }
    namespace = var.namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "system-monitor"
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
          app = "system-monitor"
        }
      }
      spec {
        host_pid = true
        host_ipc = true
        #host_network= true
        volume {
          name = "host-filesystem"
          host_path {
            path = "/"
          }
        }
        container {
          image             = "madhuakula/k8s-goat-system-monitor"
          image_pull_policy = "Always"
          name              = "system-monitor"
          resources {
            limits = {
              cpu    = "20m"
              memory = "50Mi"
            }
          }
          security_context {
            allow_privilege_escalation = true
            privileged                 = true
          }
          port {
            container_port = 8080
          }
          volume_mount {
            name       = "host-filesystem"
            mount_path = "/host-system"
          }
          env {
            name = "K8S_GOAT_VAULT_KEY"
            value_from {
              secret_key_ref {
                name = "goatvault"
                key  = "k8sgoatvaultkey"
              }
            }
          }
        }
        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service_v1" "system_monitor_service" {
  metadata {
    labels = {
      app = "system-monitor"
    }
    name      = "system-monitor-service"
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
      app = "system-monitor"
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "system_monitor_ingress" {
  wait_for_load_balancer = true

  metadata {
    annotations = {
      "alb.ingress.kubernetes.io/scheme"        = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"   = "ip"
      "kubernetes.io/ingress.class"             = "alb"
      "alb.ingress.kubernetes.io/inbound-cidrs" = var.access_ip
    }
    labels = {
      app = "system-monitor"
    }
    name      = "system-monitor-ingress"
    namespace = var.namespace
  }
  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "system-monitor-service"
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
