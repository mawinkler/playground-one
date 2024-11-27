# ####################################
# Kubernetes Metrics Server
# ####################################
# The Kubernetes Metrics Server is an aggregator of resource usage data in your cluster, 
# and it isn’t deployed by default in Amazon EKS clusters.
# https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html

# If you are using Fargate, you will need to change this file. In the default configuration,
# the metrics server uses port 10250. This port is reserved on Fargate. Replace references to
# port 10250 in components.yaml with another port, such as 10251.
data "http" "metrics_server_manifest" {
  url = "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
}

# Split the file content into multiple YAML documents
locals {
  yaml_documents = [for yaml in split("---", data.http.metrics_server_manifest.response_body) :
    yamldecode(trimspace(yaml))
    if length(trimspace(yaml)) > 0 # Ignore empty documents
  ]
}

# Apply each YAML document as a separate manifest resource
resource "kubernetes_manifest" "apply_metrics_server" {

  for_each = { for idx, doc in local.yaml_documents : tostring(idx) => doc }
  manifest = each.value
}
