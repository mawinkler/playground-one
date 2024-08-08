# Getting Started Configuration

Playground One is controlled by the command line interface `pgo`.

Use it to interact with the Playground One by running

```sh
pgo
```

from anywhere in your terminal.

> ***Note:*** If `pgo` is not found create a new shell to load the environment or run `. ~/.bashrc`.

## Getting Help

Run:

```sh
pgo --help
```

```sh
 __                 __   __   __             __      __        ___ 
|__) |     /\  \ / / _` |__) /  \ |  | |\ | |  \    /  \ |\ | |__  
|    |___ /~~\  |  \__> |  \ \__/ \__/ | \| |__/    \__/ | \| |___ 
                                                                   
Usage: pgo -<command> <configuration> ...

The available commands for execution are listed below.
The primary workflow commands are given first, followed by
less common or more advanced commands.

Main commands:
  -c --config    Set/update Playground One main configuration
  -i --init      Prepare a configuration for other commands
  -a --apply     Create or update a configuration
  -l --list      List applied configurations
  -d --destroy   Destroy previously-created configuration
  -o --output    Show output values
  -s --state     Show the current state
  -E --erase     Cleanup Terraform state
  -h --help      Show this help

Other commands:
  -S --show      Show advanced state
  -u --updateip  Update access IP(s)
  -U --update    Update Playground One and components
  -v --validate  Check whether the configuration is valid
  -p --plan      Plan apply and destroy

Available configurations:
  user                PGO User configuration
  nw                  Network configuration
  ec2                 EC2 configuration
  eks-ec2             EKS configuration
  eks-fg              EKS configuration
  ecs-ec2             ECS configuration
  ecs-fg              ECS configuration
  s3scanner           S3 Bucket scanner
  kind                Kind configuration
  scenarios-ec2       Scenario configuration
  scenarios-fg        Scenario configuration
  scenarios-cspm      Scenario configuration
  scenarios-identity  Scenario configuration
  scenarios-kind      Scenario configuration
  scenarios-aks       Scenario configuration
  dsm                 Deep Security configuration
  dsw                 Deep Security Workload configuration
  aks                 AKS configuration
  all                 All configurations

Examples:
  pgo --apply nw
  pgo --state all
```

## Configure

> ***Note:*** When using AWS you need to know your Account ID, for Azure you need your Subscription ID. Get these IDs using the following commands:
>
> `aws sts get-caller-identity | jq -r '.Account'`
> 
> `az account list | jq -r '.[] | [.name, .id] | @tsv'`

If you intent to use the Playground One user on AWS run the following commands now:

```sh
pgo --init user
pgo --apply user
```

This will create a user account in AWS with the necessary permissions only. The credetials are automatically set in the `config.yaml`.

After bootstrapping you need to configure Playground One. To simplify the process use the built in configuration tool. An eventually already existing `config.yaml` will be saved as `config.yaml.bak`. Run

```sh
pgo --config
```

This process will create or update your personal `config.yaml`. Eventually existing setting will be shown in square brackets. To accept them just press enter.

The configuration tool is devided into sections. The following chapters walk you through the process.

### Section: Playground One

You don't necessarily need to change anything here if you're satisfied with the defaults, but

> ***Note:*** It is highly recommended to change the `Access IPs/CIDRs` to (a) single IP(s) or at least a small CIDR to prevent anonymous users playing with your environmnent. Remember: we might deploy vulnerable applications.

Set/update:

- `Initialize Terraform Configurations`: Set this to `true` if you want to download the required Terraform providers. You need to do this on a new installation of Playground One at least once. If you want to reconfigure Playground One later on you can set it to false, which will speed up the reconfiguration process. 
- `PGO Environment Name`: Your to be built environment name. It MUST NOT be longer than 12 characters.
- `Access IPs/CIDRs`:
  - If you're running on a local Ubuntu server or are using Playground One Container locally (not on Cloud9), get your public IP and set the value to `<YOUR IP>/32` or type `pub` and let the config tool detect your public IP.
  - If you're working on a Cloud9 you need to enter a second public IP/CIDRs.
    1. Public IP from your Cloud9 or type `pub`.
    2. Public IP from your local client.  
  - If you want someone else grant access to your environment just add another IP/CIDR.
  - Examples:
    - `pub`
    - `pub, 86.120.222.205`
    - `3.121.226.247/32, 86.120.222.20/32`
    - `0.0.0.0/0` *Dangerous!*
- `Running in Product Experience`: Leave this to false unless you're running Playground One inside the Product Experience Platform.

> If your IP address has changed see [FAQ](../faq.md#my-ip-address-has-changed-and-i-cannot-access-my-environment-anymore).

### Section: AWS

> ***Note:*** This section is skipped when you have any configuration applied.

Set/update:

- `Account ID`: The ID of your AWS subscription (just numbers no `-`). This is mandatory.
- `Region Name`: If you want to use another region as `eu-central-1`.
- `Use PGO User`: The Playground One has the ability to create and use a dedicated AWS user with limited privileges. If you want to use this feature you need to run `pgo --apply user` after you have finished the configuration of the Playground One. This will then create a User within a Group with several IAM policies attached.
- `AD - create PGO Active Directory`: Enable/disable deployment of an Active Directory. This AD is more flexible compared to the AWS Managed Active Directory below.
- `AD - create Managed Active Directory`: Enable/disable deployment of an AWS Managed Active Directory.
- `SG - create Service Gateway`: Enable/disable deployment of the Trend Micro Service Gateway.
- `EC2 - create Linux EC2`: Enable/disable Linux instances in the `ec2` configuration.
- `EC2 - create Windows EC2`: Enable/disable Windows instances in the `ec2` configuration.

### Section: Azure

Set/update:

- `Azure Subscription ID`: The ID of your Azure subscription. This is mandatory.
- `Azure Region Name`: If you want to use another region as `westeurope`.

### Section: Vision One Configuration

Set/update:

- `Vision One API Key`: Your Vision One API Key.
- `Vision One Region Name`: Your Vision One Region.
- `Vision One ASRM - create Potential Attack Path(s)`: Create potential attack path detections for ASRM.
- `Enable Vision One Container Security`: Enable or disable the Container Security deployment. If set to `false` Cloud One configuration will be skipped.
- `Vision One Container Security Policy Name`: The name of the Policy to assign.
- `Vision One Container Security Cluster Group ID`: The Cluster Group ID to go.

### Section: Kubernetes Deployments

Set/update:

- `Deploy Calico`: Enable/disable the most used Pod network on your EKS cluster. It's currently disabled by default but will come shortly
- `Deploy Prometheus & Grafana`: Enable/disable Prometheus. It is an open-source systems monitoring and alerting toolkit integrated with a preconfigured Grafana.
- `Deploy Trivy`: Enable/disable Trivy vulnerability scanning for comparison.
- `Deploy Istio`: Enable/disable for EKS EC2.
- `Deploy MetalLB`: Enable/disable MetalLB for Kind cluster.

### Section: Deep Security (on-prem)

Set/update:

- `Deep Security`: Enable or disable the Deep Security deployment. If set to `false` Deep Security configuration will be skipped.
- `Deep Security License`: Your Deep Security license key.
- `Deep Security Username`: Username of the MasterAdmin.
- `Deep Security Password`: Password of the MasterAdmin.

Now, continue with the chapter [General Life-Cycle](life-cycle.md).