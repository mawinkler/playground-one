# Vision One Container Security

## Container Security with the Playground One EKS EC2 Cluster

This guide provides step-by-step instructions on how to deploy Vision One Container Security on a Playground One EKS EC2 cluster.

There is currently no way to fully automate the Vision One Container Security deployment the an EKS cluster. This process will be automated in the near future so that Vision One Container Security can be deployed via Terraform.

Prerequisites:

- Deployed eks cluster configuration (`pgo -a eks-ec2`).

Required information:

- EKS Cluster ARN from eks outputs (`pgo -o eks-ec2`).

Steps:

1. Head over to `Cloud Security Operations --> Container Security --> Container Inventory`.
2. Select `[Kubernetes] --> [+ Add Cluster]`.
3. Type in a name to use to identify the cluster.
4. Set `Map to Cloud Account` to `Yes` and paste the cluster ARN from the outputs of the `eks`-configuration.
5. Click the `Runtime Scanning` switch to enable Runtime Vulnerability Scanning.
6. Click the `Runtime Security` switch to enable Runtime Security protection.
7. Clich `[Next]` to create the cluster in the inventory view.
8. Download the generated `overrides.yaml`, copy/paste the `helm install` command to your terminal, and run the command. This will deploy Vision One Container Security to your EKS cluster.

Done.

## Container Security with the Playground One EKS Fargate Cluster

This guide provides step-by-step instructions on how to deploy Vision One Container Security on a Playground One EKS Fargate cluster.

There is currently no way to fully automate the Vision One Container Security deployment the an EKS cluster. This process will be automated in the near future so that Vision One Container Security can be deployed via Terraform.

Prerequisites:

- Deployed eks cluster configuration (`pgo -a eks-fg`).

Required information:

- EKS Cluster ARN from eks outputs (`pgo -o eks-fg`).

Steps:

1. Head over to `Cloud Security Operations --> Container Security --> Container Inventory`.
2. Select `[Kubernetes] --> [+ Add Cluster]`.
3. Type in a name to use to identify the cluster.
4. Set `Map to Cloud Account` to `Yes` and paste the cluster ARN from the outputs of the `eks`-configuration.
5. Click the `Runtime Scanning` switch to enable Runtime Vulnerability Scanning.
6. Click the `Runtime Security` switch to enable Runtime Security protection.
7. Clich `[Next]` to create the cluster in the inventory view.
8. Click the `Fargate environment` switch to enable Fargate support.
9. Download the generated `overrides.yaml`, copy/paste the `helm install` command to your terminal, and run the command. This will deploy Vision One Container Security to your EKS cluster.

Done.

## Container Security with the Playground One ECS Fargate Cluster

If you are deploying Container Security in an ECS Fargate environment, you have to carry out some additional steps after adding the instance. See official [documentation](https://docs.trendmicro.com/en-us/enterprise/trend-vision-one/cloudsecurityoperati/about-container-secu/next-steps/containerinventory/ecs-fargate-deployme/ecs-fargate-add.aspx) for the details.

Playground One simplifies these steps.

Prerequisites:

- Deployed ECS Fargate cluster configuration (`pgo -a ecs`).

Required information:

- ECS Fargate Cluster name from ecs outputs (`pgo -o ecs`).

Steps:

1. On Vision One, head over to `Cloud Security Operations --> Container Security --> Container Inventory`.
2. Select `[Amazon ECS] --> [Account ID] --> [Region] --> [Your ECS Fargate Cluster]`.
3. Select a Policy and enable Runtime Security.
4. Run `ecsfg-add-v1cs <CLUSTER NAME>`

Done.

> ***Note:*** Deletion of the cluster via `pgo -d ecs` will fail until you manually delete the `trendmicro-scout`-service in the ECS console. Then delete the cluster in the console. There will be an IAM policy starting with your cluster name not being deleted automatically.
