# Playground One AWS Configurations

The Playground One has a modular structure as shown in the following tree:

```
awsone
├── network (2-network)
|   ├── ec2 (3-instances)
|   ├── eks (4-cluster-eks-ec2)
|   |   ├── eks-deployments (8-cluster-eks-ec2-deployments)
|   |   └── scenarios (7-scenarios-ec2)
|   ├── eks (4-cluster-eks-fargate)
|   |   ├── eks-deployments (8-cluster-eks-fargate-deployments)
|   |   └── scenarios (7-scenarios-fargate)
|   └── ecs (5-cluster-ecs)
├── s3scanner (6-bucket-scanner)
└── dsm (9-deep-security)
    └── workload (9-deep-security-workload) 
```

As we can see, the configuration `network` is the base for the other configurations. It creates the VPC, Subnets, Route Tables, Security Groups, etc. One can choose to only create the EKS cluster, or ECS cluster, or even the full stack. Everything will reside in the same VPC.

The following chapters describe the different configurations on a high level, refer the the dedicated documentation for more details.

## Virtual Private Cloud and Network

*Configuration located in `awsone/2-network`*

This configuration defines a network with the most commonly used architecture, private and public subnets accross three availability zones. It includes everything what a VPC should have, this is amongst others an internet gateway, NAT gateway, security groups, etc. Since a VPC is cheap there's no real need to destroy the networking configuration everyday, just leave it as it is and reuse it the next time. This eases the handling of other components.

In addition to the networking things the following central services can be deployed optionally:

- Active Directory including a Certification Authority: An AD the PGO way based on cheap `t2.micro` instances.
- AWS Managed Active Directory: The AWS native variant. This is more on the expensive side (USD 96.48/mo).
- Trend Service Gateway. The configured and recommended instance type `c5.2xlarge` (8 vCPU, 16GiB, 10 Gigabit) is 0.388 USD/h, just to note.

## Virtual Instances

*Configuration located in `awsone/3-instances`*

*Depends on `awsone/2-network`*

Basically, a couple of EC2 instances are created with this configuration. Currently these are two linux and one windows instances. One of the linux instances can be used to demo a potential attack path to RDS.

If you store the agent installers for Server and Workload Security in `0-files` the instances will connect to Vision One.

You can optionally drop any file or installer in the `0-files` directory which will then be available in the ec2 instances download folder.

## EKS EC2 Cluster

*Configuration located in `awsone/4-cluster-eks-ec2`*

*Depends on `awsone/2-network`*

So, this is my favorite part. This configuration creates an EKS cluster with some nice key features:

- Autoscaling from 1 to 10 nodes
- Nodes running as Spot instances to save money :-)
- ALB Load Balancer controller
- Kubernetes Autoscaler
- Cluster is located in the private subnets

### Cluster Deployments

*Configuration located in `awsone/8-cluster-ec2-deployments`*

*Depends on `awsone/4-cluster-eks-ec2`*

Currently, the following deployments are defined:

- Container Security
- Calico
- Prometheus & Grafana
- Trivy

### Scenarios

*Configuration located in `awsone/7-scenarios-ec2`*

*Depends on `awsone/4-cluster-eks-ec2`*

Currently, the following (vulnerable) deployments are defined:

- WebApp System-Monitor (see [Escape to the Host System](../scenarios/eks/escape.md))
- WebApp Health-Check (see [ContainerD Abuse](../scenarios/eks/dind-exploitation.md))
- WebApp Hunger-Check (see [Hunger Check](../scenarios/eks/hunger-check.md))
- Java-Goof
- Nginx

Automated attacks are running every full hour.

## EKS Fargate Cluster

*Configuration located in `awsone/4-cluster-eks-fargate`*

*Depends on `awsone/2-network`*

This configuration creates a Fargate EKS cluster with some nice key features:

- Fargate Profiles
- Nodes running as Spot instances to save money :-)
- An additional AWS managed node group
- Cluster is located in the private subnets

### Cluster Deployments

*Configuration located in `awsone/8-cluster-fargate-deployments`*

*Depends on `awsone/4-cluster-eks-fargate`*

Currently, the following deployments are defined:

- Container Security
- Calico

### Scenarios

*Configuration located in `awsone/7-scenarios-fargate`*

*Depends on `awsone/4-cluster-eks-fargate`*

Currently, the following (vulnerable) deployments are defined:

- Java-Goof
- Nginx

Automated attacks are running every full hour.

## ECS EC2 Cluster

*Configuration located in `awsone/5-cluster-ecs-ec2`*

*Depends on `awsone/2-network`*

Here we're building an ECS cluster using EC2 instances. Key features:

- Autoscaling group for spot instances. On-demand autoscaler can be enabled in Terraform script.
- ALB Load Balancer
- Automatic deployment of a vulnerable service (Java-Goof)

## ECS Fargate Cluster

*Configuration located in `awsone/5-cluster-ecs-fargate`*

*Depends on `awsone/2-network`*

Here we're building an ECS cluster using Fargate profile. Key features:

- Fargate profile with spot instances. Fargate with on-demand instances can be enabled in Terraform script.
- ALB Load Balancer
- Automatic deployment of a vulnerable service (Java-Goof)

## S3 Bucket Scanner

*Configuration located in `awsone/6-bucket-scanner`*

Simple S3 Bucket scanner using the File Security Python SDK within a Lambda Function. Scan results will show up on the Vision One console.

## Deep Security

*Configuration located in `awsone/9-deep-security` and `awsone/9-deep-security-workload`*

This configuration is to simulate an on-premise Deep Security environment meant to be used in integration and migration scenarios. For simulation purposes it creates a dedicated VPC with the most commonly used architecture, private and public subnets accross two availability zones. It includes everything what a VPC should have, this is amongst others an internet gateway, NAT gateway, security groups, etc.

The workload configuration creates a demo configuration for Deep Security and two custom policies. Two linux and one windows instances are created and activated with Deep Security. Some minutes after instance creation the activated computers will run a recommendation scan.

Check the Scenarios section to see available integration and migration scenarios.

## Instance Types in Use as of 06/20/24

Region: `eu-central-1`

Instance name | On-Demand hourly rate | vCPU | Memory | Storage | Network performance | Configuration
------------- | --------------------- | ---- | ------ | ------- | ------------------- | -------------
t2.micro | $0.0134 | 1 | 1 GiB | EBS Only | Low to Moderate | Deep Security Bastion
t3.medium | $0.048 | 2 | 4 GiB | EBS Only | Up to 5 Gigabit | Various
t3.xlarge | $0.192 | 4 | 16 GiB | EBS Only | Up to 5 Gigabit | Deep Security Manager
c5.2xlarge | $0.388 | 8 | 16 GiB | EBS Only | Up to 10 Gigabit | Service Gateway
