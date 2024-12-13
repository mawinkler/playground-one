# #############################################################################
# Kind Cluster
# #############################################################################
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "kind_cluster" "kind" {
  name            = "${var.environment}-kind-${random_string.suffix.result}"
  kubeconfig_path = local.k8s_config_path
  node_image      = "kindest/node:v${var.kubernetes_version}"
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      api_server_port     = 6443
      # disable_default_cni = true
      # pod_subnet          = "192.168.0.0/16"
      pod_subnet = "10.10.0.0/16"
    }

    node {
      role = "control-plane"

      # Docker Socket
      extra_mounts {
        host_path      = "/var/run/docker.sock"
        container_path = "/var/run/docker.sock"
      }
      # Falco
      extra_mounts {
        host_path      = "/dev"
        container_path = "/dev"
      }
      extra_mounts {
        host_path      = "/usr/src"
        container_path = "/usr/src"
      }
      # Kube Audit
      extra_mounts {
        host_path      = "${var.one_path}/log/"
        container_path = "/var/log/"
      }
      extra_mounts {
        host_path      = "audit/"
        container_path = "/var/lib/k8s-audit/"
      }

      # Ingress and audit
      kubeadm_config_patches = [
        <<EOF
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    node-labels: "ingress-ready=true"

kind: ClusterConfiguration
apiServer:
  extraArgs:
    audit-log-path: "/var/log/k8s-audit.log"
    audit-log-maxage: "3"
    audit-log-maxbackup: "1"
    audit-log-maxsize: "10"
    audit-policy-file: "/var/lib/k8s-audit/audit-policy.yaml"
    # audit-webhook-batch-max-wait: "5s"
    audit-webhook-config-file: "/var/lib/k8s-audit/audit-webhook.yaml"
  extraVolumes:
  - name: audit
    hostPath: /var/log/
    mountPath: /var/log/
  - name: auditcfg
    hostPath: /var/lib/k8s-audit/
    mountPath: /var/lib/k8s-audit/
EOF
      ]
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        listen_address = "0.0.0.0"
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
        listen_address = "0.0.0.0"
      }
      # # Falco Sidekick-UI
      # extra_port_mappings {
      #   container_port = 2802
      #   host_port      = 2802
      # }
    }

    node {
      role = "worker"
    }

    # node {
    #   role = "worker"
    # }
  }
}
