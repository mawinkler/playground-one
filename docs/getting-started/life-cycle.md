# General Life-Cycle

The life-cycle of Playground One is controlled by the command line interface `pgo`.

Use it to interact with the Playground One from anywhere in your terminal by running

```sh
$ pgo
```

from anywhere in your terminal.

## Getting Help

Run:

```sh
$ pgo --help
```

```sh
Usage: pgo <command> <configuration> ...

The available commands for execution are listed below.
The primary workflow commands are given first, followed by
less common or more advanced commands.

Main commands:
  -i --init     Prepare a configuration for other commands
  -a --apply    Create of update infrastructure
  -d --destroy  Destroy previously-created infrastructure
  -o --output   Show output values
  -s --state    Show the current state
  -h --help     Show this help

Other commands:
  -S --show     Show advanced state
  -v --validate Check whether the configuration is valid

Available configurations:
  vpc           VPC configuration
  nw            Network configuration
  ec2           EC2 configuration
  eks           EKS configuration
  ecs           ECS configurations
  all           All configurations

Examples:
  pgo --apply vpc
  pgo --state all
```

## Create the Environment

1. Initialize with

    ```sh
    $ pgo --init all
    ```

    This will prepare all available configurations. No changes done in the clouds yet. You only need to init once after cloning the repository.

2. To create the VPC run

    ```sh
    $ pgo --apply vpc
    ```

    This will create your VPC in the configured region (see `config.yaml`)

3. To create the Network run

    ```sh
    $ pgo --apply nw
    ```

    This will create your network in the configured vpc

4. Create Virtual Instances and/or Kubernetes Clusters with demo workload

    EC2 instances:

    ```sh
    $ pgo --apply ec2
    ```

    EKS cluster:

    ```sh
    $ pgo --apply eks
    ```

    The default workload (Container Security, Trivy, and vulnerable apps) are deployed automatically.

    ECS cluster:

    ```sh
    $ pgo --apply ecs
    ```

    A default workload is deployed automatically.

## Query Outputs and State

The most relevant information on your configuration can be queried by running

```sh
$ pgo --output <configuration>
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

## Tear Down

If you want to destroy your environment completely or only parts of it

```sh
$ pgo --destroy <configuration>
```

If you want to tear down everything run

```sh
$ pgo --destroy all
```

> ***Note:*** The VPC is not automatically destroyed. You can do this manually by running `pgo --destroy vpc`.

## Optional: Adapt `terraform.tfvars` in Configurations

The `terraform.tfvars`-files located within the configurations allow you to configure the AWS One playground in some aspects. Normally there's nothing to do for you, but if you only need Linux servers you could disable windows instance(s) in `3-instances/terraform.tfvars`.
