resource "kubernetes_namespace" "echoserver" {
  metadata {
    name = "echoserver"
  }
}

resource "kubernetes_deployment" "echoserver" {
    depends_on = [ kubernetes_namespace.echoserver ]
  metadata {
    name      = "echoserver"
    namespace = "echoserver"
    labels = {
      App = "echoserver"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "echoserver"
      }
    }
    template {
      metadata {
        labels = {
          App = "echoserver"
        }
      }
      spec {
        container {
          image = "jmalloc/echo-server"
          name  = "echoserver"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "echoserver" {
    depends_on = [ kubernetes_deployment.echoserver ]
    metadata {
        name = "echoserver"
        namespace = "echoserver"
    }
    spec {
        selector = {
            App = "echoserver"
        }
        port {
            port = 8080
            target_port = 8080
        }
    }
}

resource "kubectl_manifest" "echoserver_httpproxy" {
  depends_on = [helm_release.projectcontour, kubernetes_service.echoserver]
  yaml_body  = <<YAML
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: echoserver
  namespace: echoserver
spec:
  virtualhost:
    fqdn: localhost
  routes:
    - services:
      - name: echoserver
        port: 8080
YAML
}