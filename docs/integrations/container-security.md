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
