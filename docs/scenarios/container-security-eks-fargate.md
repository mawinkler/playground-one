# Scenario: Runtime Vulnerability Scanning on EKS Fargate

***DRAFT***

## Prerequisites

- Vision One Container Security
- Playground One EKS Cluster with Fargate Profile
- Playground One Scenarios
  - Running app: Nginx

Ensure to have the EKS Cluster with the Fargate profile enabled up and running:

```sh
pgo --config
# verify that:
# EKS - create Fargate profile [true]:
# is true, otherwise set it to true

# If you changed the config for Fargate run
pgo --init eks
pgo --init scenarios

# Ensure to have eks and the scenarios deployed
pgo --apply eks
pgo --apply scenarios
```

## Disclaimer

> ***Note:*** It is highly recommended to have the `awsone.access_ip` set to a single IP or at least a small CIDR before deploying the EKS cluster. This will prevent anonymous users playing with your environmnent. Remember: we're using vulnerable apps.

## Overview

This scenario showcases the vulnerability detection functionalities of Vision One Container Security at runtime for EKS with Fargate profiles.

By the end of the scenario, you will understand and learn the following:

- Reviewing vulnerability findings and searching for a specific vulnerability

## The story

Here we're checking for the [CVE-2021-3711](https://nvd.nist.gov/vuln/detail/cve-2021-3711) in OpenSSL with a criticality of 9.8 (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H).

You want to search this specific vulnerability in your production environment.

## Goals

The goal of this scenario is to identify the vulnerable deployment and proof that it is vulnerable.

### Hints

<details>
<summary>Click here</summary>

✨ Didn't find the vulnerable deployment?
<br><br>
Head over to Container Security --> Runtime vulnerability and search for CVE-2017-5638. 🙌
<br><br>

</details>

## Solution & Walkthrough

<details>
<summary>Click here</summary>

Head over to Attack Surface Risk Managemet and search for the vulnerability CVE-2021-3711

Identify the vulnerable deployment/container.

Find out the node(s) running the pod(s).

```sh
kubectl get pods -A -o wide
```

You'll see that the deployment is running within the `fargate` namespace. The name(s) of the worker nodes start with `fargate-ip-...` which indicate that these nodes are AWS managed Fargate nodes.

Checking the services in the namespace `fargate` 

```sh
kubectl -n fargate get services
```

tells us

```
NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
nginx-service   NodePort   172.20.48.60   <none>        80:32443/TCP   26m
```

🎉 Success 🎉

</details>
