# Vision One Container Security

## Setup of Container Security with the Playground One

This guide provides step-by-step instructions on how to deploy Vision One Container Security on a Playground One EKS cluster.

There is currently no way to fully automate the Vision One Container Security deployment the an EKS cluster. This process will be automated in the near future so that Vision One Container Security can be deployed via Terraform.

Prerequisites:

- Deployed eks cluster configuration (`pgo -a eks`).

Required information:

- EKS Cluster ARN from eks outputs (`pgo -o eks`).

Steps:

1. Head over to `Cloud Security Operations --> Container Security --> Container Inventory`.
2. Select `[Kubernetes] --> [+ Add Cluster]`.
3. Type in a name to use to identify the cluster.
4. Set `Map to Cloud Account` to `Yes` and paste the cluster ARN from the outputs of the `eks`-configuration.
5. Click the `Runtime Scanning` switch to enable Runtime Vulnerability Scanning.
6. Click the `Runtime Security` switch to enable Runtime Security protection.
7. Clich `[Next]` to create the cluster in the inventory view.
8. Download the generated `overrides.yaml` and copy/paste the `helm install` command to your terminal. This will deploy Vision One Container Security to your EKS cluster.

## (Outdated): Cloud One Container Security

Container Security can automatically be deployed to the EKS cluster of Playground One if enabled in the configuration. If you provided a proper Cloud One information it is already up and running.

Required information:

- Trend Cloud One API Key
- Trend Cloud One Region

Optional information:

- Container Security Policy ID

To get the Policy ID head over to Container Security on Cloud One and navigate to the policy. The Policy ID is the part after the last `/` in the URL:

```ascii
https://cloudone.trendmicro.com/container/policies/relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured
```

Here: `relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured`

If you don't configure a policy ID you'll need to assign one within the Cloud One console.

## Scenarios

- [Escape to the Host System](../scenarios/container-security-eks-escape.md)
- [ContainerD Abuse](../scenarios/container-security-eks-dind-exploitation.md)
- [Runtime Vulnerability Scan on EKS](../scenarios/container-security-eks-runtime-vulnerability.md)
- [Runtime Vulnerability Scan on ECS](../scenarios/container-security-ecs-runtime-vulnerability.md)
- [Runtime Violations](../scenarios/container-security-eks-runtime-violations.md)
