# Bloopers during development

- [Bloopers during development](#bloopers-during-development)
  - [Terraform](#terraform)
    - [Delete all resources except one](#delete-all-resources-except-one)
  - [EKS](#eks)
    - [Unable to delete ingress](#unable-to-delete-ingress)
    - [Unable to delete namespace](#unable-to-delete-namespace)
    - [EKSWorkerNode is not joining Node Group](#eksworkernode-is-not-joining-node-group)
    - [EKS Service behind ALB shows only HTML](#eks-service-behind-alb-shows-only-html)
  - [XDR for Containers](#xdr-for-containers)

## Terraform

### Delete all resources except one

There is no --except feature in terraform destroy command currently. If you really want to do that, and you know what you are doing, here is the workaround.

```sh
# list all resources
terraform state list

# remove that resource you don't want to destroy
# you can add more to be excluded if required
terraform state rm <resource_to_be_deleted> 

# destroy the whole stack except above excluded resource(s)
terraform destroy 
```

So why do these commands work for your idea?

The state (*.tfstate) is used by Terraform to map real world resources to your configuration, keep track of metadata.

terraform state rm cleans a record (resource) from the state file (*.tfstate) only. It doesn't destroy the real resource.

Since you don't run terraform apply or terraform refresh, after terraform state rm, terraform doesn't know the excluded resource was created at all.

When you run terraform destroy, it has no detail about that excluded resource’s state and will not destroy it. It will destroy the rest.

By the way, later you still have chance to import the resource back with terraform import command if you want.

```sh
terraform import module.vpc.aws_vpc.vpc vpc-0933149e01f1136aa
```

## EKS

### Unable to delete ingress

```sh
kubectl delete ValidatingWebhookConfiguration aws-load-balancer-webhook
kubectl patch ingress $Ingressname -n $namespace -p '{"metadata":{"finalizers":[]}}' --type=merge
```

### Unable to delete namespace

To delete a namespace, Kubernetes must first delete all the resources in the namespace. Then, it must check registered API services for the status. A namespace gets stuck in Terminating status for the following reasons:

- The namespace contains resources that Kubernetes can't delete.
- An API service has a False status.

1. Save a JSON file like in the following example:

```sh
kubectl get namespace TERMINATING_NAMESPACE -o json > tempfile.json
```

2. Remove the finalizers array block from the spec section of the JSON file:

```json
"spec": {
        "finalizers": [
            "kubernetes"
        ]
    }
```

After you remove the finalizers array block, the spec section of the JSON file looks like this:

```json
"spec" : {
    }
```

3. To apply the changes, run the following command:

```sh
kubectl replace --raw "/api/v1/namespaces/TERMINATING_NAMESPACE/finalize" -f ./tempfile.json
```

4. Verify that the terminating namespace is removed:

```sh
kubectl get namespaces
```

Repeat these steps for any remaining namespaces that are stuck in the Terminating status.

### EKSWorkerNode is not joining Node Group

This does help to identify the problem:

- <https://repost.aws/knowledge-center/resolve-eks-node-failures>
- <https://docs.aws.amazon.com/systems-manager-automation-runbooks/latest/userguide/automation-awssupport-troubleshooteksworkernode.html>
- <https://console.aws.amazon.com/systems-manager/automation/execute/AWSSupport-TroubleshootEKSWorkerNode>

### EKS Service behind ALB shows only HTML

```terraform
resource "kubernetes_ingress_v1" "openssl3_ingress" {
  wait_for_load_balancer = true

  metadata {
    annotations = {
      "alb.ingress.kubernetes.io/scheme"        = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"   = "ip"
      "kubernetes.io/ingress.class"             = "alb"
      "alb.ingress.kubernetes.io/inbound-cidrs" = var.access_ip
    }
    labels = {
      app = "web-app"
    }
    name      = "web-app-ingress"
    namespace = var.namespace
  }
  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "web-app-service"
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
```

The `*` in `path` is important :-)

## XDR for Containers

Initially, I thought I just need to leave the VPC alone when changing/destroying part of the network configuration. This was a failure...