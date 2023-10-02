# General Life-Cycle

## Create the Environment

1. Initialize with

    ```sh
    pgo --init all
    ```

    This will prepare all available configurations. No changes done in the clouds yet. You only need to init once after cloning the repository.

    If you have changed Playground Ones main configuration using `pgo --config` please rerun `pgo --init all` again to apply eventual changes to the configurations.

2. To create the VPC and Network run

    ```sh
    pgo --apply nw
    ```

    This will create your VPC and network in the configured region (see `config.yaml`)

3. If you want your EC2 instances to be connected to Vision One Endpoint Security head over to [Vision One Endpoint Security Server & Workload Protection](../integrations/endpoint-security.md) and come back afterwards.

4. Create Virtual Instances and/or Kubernetes Clusters with demo workload.

    EC2 instances:

    ```sh
    pgo --apply ec2
    ```

    EKS cluster:

    ```sh
    pgo --apply eks
    ```

    ECS cluster(s):

    ```sh
    pgo --apply ecs
    ```

    A vulnerable default workload is deployed automatically.

## Query Outputs and State

The most relevant information on your configuration can be queried by running

```sh
pgo --output <configuration>
```

Example: `pgo --output ec2`:

```sh
public_instance_id_db1 = "i-072abd953dedaae5d"
public_instance_id_srv1 = "i-0f2c91e08fd054510"
public_instance_id_web1 = "i-048ecedf660236f47"
public_instance_ip_db1 = "3.76.39.227"
public_instance_ip_srv1 = "3.75.219.198"
public_instance_ip_web1 = "18.197.106.33"
public_instance_password_srv1 = <sensitive>
s3_bucket = "playground-awsone-cesh306v"
ssh_instance_db1 = "ssh -i ../playground-key-pair.pem -o StrictHostKeyChecking=no ubuntu@3.76.39.227"
ssh_instance_srv1 = "ssh -i ../playground-key-pair.pem -o StrictHostKeyChecking=no admin@3.75.219.198"
ssh_instance_web1 = "ssh -i ../playground-key-pair.pem -o StrictHostKeyChecking=no ubuntu@18.197.106.33"
public_instance_password_srv1 = "4h1v}Q7Hc9tbGWdM"
```

With this you can always query how to connect to your running EC2 instances. All instances support SSH connections, the Windows Server Remote Desktop as well. For RDP Use the configured `admin` user, the ip address and password for srv1.

## Play with the Playground One

It's a playground, or? Experiment and hopefully learn a few things. For your guidance, there are some prepared scenarios for you to go through. Find them in the navigation pane.

## Tear Down

If you want to destroy your environment completely or only parts of it

```sh
pgo --destroy <configuration>
```

If you want to tear down everything run

```sh
pgo --destroy all
```

> ***Note:*** The network and VPC are not automatically destroyed. You can do this manually by running `pgo --destroy nw`. Be sure to have the CloudFormation stack of XDR for Containers deleted before doing so. Otherwise it will be in a fail (blackhole) state.
