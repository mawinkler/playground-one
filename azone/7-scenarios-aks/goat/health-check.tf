# #############################################################################
# Deploy the vulnerable web application health-check
# #############################################################################
resource "kubernetes_deployment_v1" "health_check_deployment" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]

  metadata {
    name = "health-check"
    labels = {
      app = "health-check"
    }
    namespace = var.namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "health-check"
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
          app = "health-check"
        }
      }
      spec {
        host_pid = true
        host_ipc = true
        #host_network= true
        volume {
          name = "containerd-sock-volume"
          host_path {
            path = "/run/containerd/containerd.sock"
            type = "Socket"
          }
        }
        container {
          image             = "madhuakula/k8s-goat-health-check"
          image_pull_policy = "Always"
          name              = "health-check"
          resources {
            limits = {
              cpu    = "50m"
              memory = "100Mi"
            }
          }
          security_context {
            privileged = true
          }
          port {
            container_port = 80
          }
          volume_mount {
            name       = "containerd-sock-volume"
            mount_path = "/custom/containerd/containerd.sock"
          }
        }
        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service_v1" "health_check_service" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]

  metadata {
    labels = {
      app = "health-check"
    }
    name      = "health-check-service"
    namespace = var.namespace
  }
  spec {
    external_traffic_policy = "Cluster"
    internal_traffic_policy = "Cluster"
    port {
      port        = 80
      target_port = 80
    }
    selector = {
      app = "health-check"
    }
    # type = "ClusterIP"
    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "health_check_ingress" {
  depends_on = [kubernetes_namespace_v1.goat_namespace]
  wait_for_load_balancer = true

  metadata {
    annotations = {
      "kubernetes.io/ingress.class"             = "addon-http-application-routing"
      # "alb.ingress.kubernetes.io/inbound-cidrs" = var.access_ip
    }
    labels = {
      app = "health-check"
    }
    name      = "health-check-ingress"
    namespace = var.namespace
  }
  spec {
    # ingress_class_name = "webapprouting.kubernetes.azure.com"
    rule {
      # host = "goat.health-check-service.cluster.local"
      http {
        path {
          backend {
            service {
              name = "health-check-service"
              port {
                number = 80
              }
            }
          }
          path = "/*"
        }
      }
    }
  }
}
