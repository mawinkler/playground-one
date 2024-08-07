# Bloopers during development

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

### ECS cluster with capacity providers cannot be destroyed

The problem is that the capacity_provider property on the aws_ecs_cluster introduces a new dependency:
aws_ecs_cluster depends on aws_ecs_capacity_provider depends on aws_autoscaling_group.

This causes terraform to destroy the ECS cluster before the autoscaling group, which is the wrong way around: the autoscaling group must be destroyed first because the cluster must contain zero instances before it can be destroyed.

This leads to Terraform error out with the cluster partly alive and the capacity providers fully alive.

References:

- <https://github.com/hashicorp/terraform-provider-aws/issues/4852>
- <https://github.com/hashicorp/terraform-provider-aws/issues/11409>
- <https://github.com/hashicorp/terraform-provider-aws/pull/22672>

I haven't found a proper workaround, yet...

## EKS

### Unable to delete ingress

```sh
kubectl delete ValidatingWebhookConfiguration aws-load-balancer-webhook
kubectl patch ingress $ingressname -n $namespace -p '{"metadata":{"finalizers":[]}}' --type=merge
```

### Unable to delete namespace

To delete a namespace, Kubernetes must first delete all the resources in the namespace. Then, it must check registered API services for the status. A namespace gets stuck in Terminating status for the following reasons:

- The namespace contains resources that Kubernetes can't delete.
- An API service has a False status.

Scripted:

```sh
k8s-ns-finalizer <NAMESPACE>
```

Manual:

1. Save a JSON file like in the following example:

```sh
namespace=<NAMESPACE>

kubectl get namespace $namespace -o json > tempfile.json
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
kubectl replace --raw "/api/v1/namespaces/$namespace/finalize" -f ./tempfile.json
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

## Route53

If a hosted zone is destroyed and re-provisioned, new name server records are associated with the new hosted zone. However, the domain name might still have the previous name server records associated with it.

If AWS Route 53 is used as the domain name registrar, head to Route 53 > Registered domains > ${your-domain-name} > Add or edit name servers and add the newly associated name server records from the hosted zone to the registered domain.

## XDR for Containers

Initially, I thought I just need to leave the VPC alone when changing/destroying part of the network configuration. This was a failure...

## Misc commands which helped at some point

```sh
aws kms delete-alias --alias-name alias/eks/playground-one-eks
```

## EKS EC2 Autoscaler

In some cases creating the EKS cluster with EC2 instances failes just before finishing with the following error:

```sh
╷
│ Warning: Helm release "cluster-autoscaler" was created but has a failed status. Use the `helm` command to investigate the error, correct it, then run Terraform again.
│ 
│   with module.eks.helm_release.cluster_autoscaler[0],
│   on eks-ec2/autoscaler.tf line 25, in resource "helm_release" "cluster_autoscaler":
│   25: resource "helm_release" "cluster_autoscaler" {
│ 
╵
...
╷
│ Error: 1 error occurred:
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│ 
│ 
│ 
│   with module.eks.helm_release.cluster_autoscaler[0],
│   on eks-ec2/autoscaler.tf line 25, in resource "helm_release" "cluster_autoscaler":
│   25: resource "helm_release" "cluster_autoscaler" {
│ 
╵
```

This looks like a timing issue for me which I need to investigate further. If you run into this problem just rerun

```sh
pgo --apply eks-ec2
```

This should complete the cluster creation within seconds then.

Autoscaler Logs:

```sh
kubectl logs -f -n kube-system -l app=cluster-autoscaler
```
