# General Life-Cycle

## Initialize

Initialize with

```sh
pgo --init all
```

This will prepare all available configurations. No changes done in the clouds yet.

If you have changed Playground Ones main configuration using `pgo --config` or updated it via `git pull` please rerun `pgo --init all` again to apply eventual changes to the configurations.

## Create the AWS Environment (Examples)

1. To create the VPC and Network run

    ```sh
    pgo --apply network
    ```

    This will create your VPC and network in the configured region (see `config.yaml`)

2. If you want your EC2 instances to be connected to Vision One Endpoint Security head over to [Vision One Endpoint Security Server & Workload Protection](../integrations/endpoint-security.md) and come back afterwards.

3. Create Virtual Instances and/or Kubernetes Clusters with demo workload.

    EC2 instances:

    ```sh
    pgo --apply instances
    ```

    EKS EC2 cluster:

    ```sh
    pgo --apply eks-ec2
    ```

    > ***Note:*** If you're using the PGO user, you'll need to run `pgos` after building the cluster to get access to it for using `kubectl' commands. This will create a new shell with that user's credentials.

    EKS Fargate cluster:

    ```sh
    pgo --apply eks-fg
    ```

    > ***Note:*** If you're using the PGO user, you'll need to run `pgos` after building the cluster to get access to it for using `kubectl' commands. This will create a new shell with that user's credentials.

    ECS EC2 cluster:

    ```sh
    pgo --apply ecs-ec2
    ```

    ECS Fargate cluster:

    ```sh
    pgo --apply ecs-fg
    ```

    ...

## Create the Azure Environment

1. Create Kubernetes Cluster with demo workload.

    AKS cluster:

    ```sh
    pgo --apply aks
    ```

## Query Outputs and State

The most relevant information on your configuration can be queried by running

```sh
pgo --output <configuration>
```

Example: `pgo --output network`:

```sh
ad_admin_password = <sensitive>
ad_ca_ip = "3.79.240.102"
ad_dc_ip = "18.199.162.245"
ad_dc_pip = "10.0.4.243"
ad_domain_admin = "Administrator"
ad_domain_name = "pgo-zt.local"
database_subnet_group = "pgo-zt-vpc"
database_subnets = [
  "subnet-024061bce0457ad5a",
  "subnet-0385d854408871587",
  "subnet-05eea550f4b109560",
]
intra_subnet_cidr_blocks = tolist([
  "10.0.20.0/24",
  "10.0.21.0/24",
  "10.0.22.0/24",
])
intra_subnets = [
  "subnet-0e11990df7299c915",
  "subnet-0b5aecdff3e5673a1",
  "subnet-0e29a813d1fc4db82",
]
key_name = "pgo-zt-key-pair-fuhp9d81"
nat_ip = "3.73.242.255"
private_key_path = "/home/markus/projects/opensource/playground/playground-one/pgo-zt-key-pair-fuhp9d81.pem"
private_security_group_id = "sg-09685580098cdbbbb"
private_subnet_cidr_blocks = tolist([
  "10.0.0.0/24",
  "10.0.1.0/24",
  "10.0.2.0/24",
])
private_subnets = [
  "subnet-04c67c83d6cbac862",
  "subnet-0b641ee8a642ee59b",
  "subnet-053aa013e78f082c9",
]
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxtSTOrR4TVxVvz1UWjsR7QxDS99DlHSx3YE7olWGQGraifnW9z2fL9SadHYMeEMgitRndyVRFOWNoMEdsixnwr5UMewUZCPeVmuifZLPSleVhdsjDmEKsvlyed6tbTCFsH/NseNI9GOzGShHravWqkGvKQysT550/xlcjH8NUYpJqRPWVcDatedxuQZdRidWJu3lPmDYOxEYzb7lPdi/sAT4Y6e9VXv7/kc1EWuM+DB/Z6b40hxl8ud+bomk3z+2GxmqdCTbXkQqt+eiSxJirZV7m1xEhfAOBwlzdeTAX7iKJoIAtP+4hCACPcpXi5QU+ufiqpwTnH9XyF42vlpvgiCrSyF7KEKCOTTFmSkin6UDhcqtsHwdRDraszSQcgzrdUSr5qh3xhK9DGymPSLjH5fDAE/NY8FXS1YiJuOBNDz8SVjiIIKJfvO69QGrMo+rtrKySSrLWXHPE2rpTzPnNZA4xfAiIgObzTFpska+9dqeaSgYO/Bf7ZciEcFJsYNVHDisANPeiqDMZ8gL5YIs1cpKL8HtP/MQ9vmk/GvqGdKrjJbpFx5Ck75R4V43ALmY+sYEXrwuqsCEHVaI5M8azduQoYk/7gmMWrwRyZVndRx60yJjawDbOSRrw1ppqA87LlSXHWzD9MqKESA0M7Ktbl1T0UvHoGygX16TsFaeFZw=="
public_security_group_id = "sg-0450bc4f9b8b6df27"
public_subnet_cidr_blocks = tolist([
  "10.0.4.0/24",
  "10.0.5.0/24",
  "10.0.6.0/24",
])
public_subnets = [
  "subnet-0801f0e4b2d56adfb",
  "subnet-097370fd84490c194",
  "subnet-0e200500c67fc8046",
]
sg_ami = "ami-076cc3a0b6e31d873"
sg_va_ip = "35.159.85.242"
sg_va_ssh = "ssh -i /home/markus/projects/opensource/playground/playground-one/pgo-zt-key-pair-fuhp9d81.pem -o StrictHostKeyChecking=no admin@35.159.85.242"
vpc_id = "vpc-09af1cf0b47603e9e"
vpc_owner_id = "634503960501"
ad_admin_password = TrendMicro.1
```

With this you can always query details of your VPC.

## Play with the Playground One

It's a playground, or? Experiment and hopefully learn a few things. For your guidance, there are some prepared scenarios for you to go through. Find them in the navigation pane.

## Switch in between multiple Kubernetes Clusters

If you're using multiple clusters simultaneously you can easily switch in between the clusters using the command `kubie`.

Main commands:

* `kubie ctx` display a selectable menu of contexts or directly spawns a shell if there is only one context available.
* `kubie ctx <context>` switch the current shell to the given context (spawns a shell if not a kubie shell).
* `kubie ctx -` switch back to the previous context
* `kubie ns` display a selectable menu of namespaces
* `kubie ns <namespace>` switch the current shell to the given namespace
* `kubie ns -` switch back to the previous namespace

Exit a context by pressing `^d`.

Full list of kubie commands [here](https://github.com/sbstp/kubie#usage).

## Tear Down

If you want to destroy your environment completely or only parts of it

```sh
pgo --destroy <configuration>
```

If you want to tear down everything run

```sh
pgo --destroy all
```

> ***Note:*** The network and VPC are not automatically destroyed. You can do this manually by running `pgo --destroy nw`. Be sure to have the CloudFormation stack of XDR for Containers deleted before doing so. Otherwise it will be in a failed (blackhole) state.
