# Vision One Container Security

## Container Security with the Playground One EKS EC2 Cluster

This guide provides step-by-step instructions on how to use Vision One Container Security on a Playground One EKS EC2 cluster.

Prerequisites:

- Vision One API Key with the following permissions:
    - Cloud Security Operations
        - Container Inventory
            - View
            - Configure Settings
        - Container Protection
            - View

Required information:

- Name of already existing Container Protection Policy to assign to the cluster installation.

Steps:

1. Run the configuration tool with `pgo --config` to set or verify the values in the `Vision One Container Security` section.
2. Create the EKS cluster

    ```sh
    # EKS with EC2 nodes
    pgo --apply eks-ec2

    # EKS with Fargate profiles
    pgo --apply eks-fg
    ```

Done. Playground One uses the Terraform provider of Vision One Container Security.

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
