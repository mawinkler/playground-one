# Scenario: Hunger Check

## Prerequisites

- Playground One EKS EC2 Cluster
- Playground One Scenarios
    - Running app: Hunger Check

Ensure to have the EKS EC2 Cluster including the Scenarios up and running:

```sh
pgo --apply eks-ec2
pgo --apply scenarios-ec2
```

We will use the Kubernetes Metrics Server which is an aggregator of resource usage data in our cluster. The Metrics Server isn't deployed by default in Amazon EKS clusters. To deploy it run

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Attribution

This scenario is based on [Kubernetes Goat](https://madhuakula.com/kubernetes-goat/docs/) but adapted to work an Playground One and EKS.

## Disclaimer

> ***Note:*** It is highly recommended to have the `awsone.access_ip` set to a single IP or at least a small CIDR before deploying the EKS cluster. This will prevent anonymous users playing with your environmnent. Remember: we're using vulnerable apps.

## Overview

Availability is one of the triads in CIA. One of the core problems solved by Kubernetes is the management of the resources like autoscaling, rollouts, etc. In this scenario, we will see how attackers can leverage and gain access to more resources or cause an impact on the availability of the resources by performing the DoS (Denial of Service) if there were no resource management configurations implemented on the cluster resources like memory and CPU requests and limits.

By the end of the scenario, we will understand and learn the following

- Learn to perform the DoS on computing and memory resources using stress-ng
- Understand the Kubernetes resources management for pods and containers
- Explore the Kubernetes resource monitoring using the metrics and information

## The story

There is no specification of resources in the Kubernetes manifests and no applied limit ranges for the containers. As an attacker, we can consume all the resources where the pod/deployment running and starve other resources and cause a DoS for the environment.

> ***Note:*** To get started with the scenario, navigate to `http://<loadbalancer_dns_hunger_check>`

## Goals

Access more resources than intended for this pod/container by consuming 2GB of memory to successfully complete the scenario.

> ***Tip:*** If you are able to obtain containers running in the host system then you have completed this scenario. But definitely, you can advance beyond this exploitation as well by performing post-exploitation, e.g. spinning up an additional container.

### Hints

<details>
<summary>Click here</summary>

✨ How can I DoS resources?
<br><br>
You can leverage the popular command line utility like stress-ng 🙌
<br>

</details>

## Solution & Walkthrough

<details>
<summary>Click here</summary>

This deployment pod has not set any resource limits in the Kubernetes manifests. So we can easily perform a bunch of operations that can consume more resources.
<br><br>
We can use simple utilities like stress-ng to perform stress testing like accessing more resources. The below command is to access more resources than specified.

```sh
root@hunger-check-655dfcd8b9-bcfgq:/# stress-ng --vm 2 --vm-bytes 2G --timeout 30s
```
       
```sh
stress-ng: info:  [41] dispatching hogs: 2 vm
stress-ng: info:  [41] successful run completed in 30.09s
root@hunger-check-655dfcd8b9-bcfgq:/# 
```

You can see the difference between the normal resources consumption vs while running stress-ng where it consumes a lot of resources than it intended to consume. Run the following command in your local/Cloud9 shell:

```sh
watch kubectl --namespace goat top pod $(kubectl -n goat get pods --selector=app=hunger-check -o jsonpath='{.items[0].metadata.name}')
```

***DANGER***
<br><br>
This attack may not work in some cases like autoscaling, resource restrictions, etc. Also, it may cause more damage when autoscaling is enabled and more resources are created. This could lead to more expensive bills by the cloud provider or impacting the availability of the resources and services.
<br><br>
Hooray 🥳, now we can see that it can consume more resources than intended which might affect the resource availability and also increase billing.
<br><br>
🎉 Success 🎉

</details>
