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

Available configurations: vpc, nw, ec2, eks-ec2, eks-fg, ecs, scenarios-ec2, scenarios-fg

Main commands:
  -c --config   Set/update Playground One main configuration
  -i --init     Prepare a configuration for other commands
  -a --apply    Create or update a configuration
  -l --list     List applied configurations
  -d --destroy  Destroy previously-created configuration
  -o --output   Show output values
  -s --state    Show the current state
  -h --help     Show this help

Other commands:
  -S --show     Show advanced state
  -u --updateip Update access IP(s)
  -v --validate Check whether the configuration is valid

Available configurations:
  nw            Network configuration
  ec2           EC2 configuration
  eks-ec2       EKS configuration
  eks-fg        EKS configuration
  ecs           ECS configurations
  kind          Kind configuration
  scenarios-ec2 Scenario configuration
  scenarios-fg  Scenario configuration
  dsm           Deep Security configuration
  dsw           Deep Security Workload configuration
  all           All configurations

Examples:
  pgo --apply nw
  pgo --state all
```

## Configure

After bootstrapping you need to configure Playground One. To simplify the process use the built in configuration tool. An eventually already existing `config.yaml` will be saved as `config.yaml.bak`. Run

```sh
pgo --config
```

This process will create or update your personal `config.yaml`. Eventually existing setting will be shown in square brackets. To accept them just press enter.

The configuration tool is devided into sections. The following chapters walk you through the process.

### Section: AWS

> ***Note:*** This section is skipped when you have any configuration applied.

Set/update:

- `AWS Account ID`: The ID of your AWS subscription (just numbers no `-`). This is mandatory.
- `AWS region name`: If you want to use another region as `eu-central-1`.
- `AWS environment name`: Your to be built environment name. It MUST NOT be longer than 12 characters.

### Section: Playground One

You don't necessarily need to change anything here if you're satisfied with the defaults, but

> ***Note:*** It is highly recommended to change the `Access IPs/CIDRs` to (a) single IP(s) or at least a small CIDR to prevent anonymous users playing with your environmnent. Remember: we might deploy vulnerable applications.

Set/update:

- `Access IPs/CIDRs`:
  - If you're running on a local Ubuntu server (not Cloud9), get your public IP and set the value to `<YOUR IP>/32` or type `pub` and let the config tool detect your public IP.
  - If you're working on a Cloud9 you need enter two public IP/CIDRs separated by `,`.
    1. Public IP from your Cloud9 or type `pub`.
    2. Public IP from your local client.  
  - If you want someone else grant access to your environment just add another IP/CIDR.
  - Examples:
    - `pub`
    - `pub, 86.120.222.205`
    - `3.121.226.247/32, 86.120.222.20/32`
    - `0.0.0.0/0` *Dangerous!*
- `EC2 - create Linux EC2`: Enable/disable Linux instances in the `ec2` configuration.
- `EC2 - create Windows EC2`: Enable/disable Windows instances in the `ec2` configuration.
- `ECS - utilize EC2 nodes`: Enable/disable ECS cluster with EC2 nodes.
- `ECS - utilize Fargate nodes`: Enable/disable ECS cluster with Fargate nodes.

> If your IP address has changed see [FAQ](../faq.md#my-ip-address-has-changed-and-i-cannot-access-my-apps-anymore).

### Section: Container Security ***(currently disabled)***

> ***Note:*** Configuration and automated deployment currently disabled due to missing APIs.

Set/update:

- `Container Security`: Enable or disable the Container Security deployment. If set to `false` Cloud One configuration will be skipped.
- `Container Security policy ID`: To get the Policy ID for your Container Security deployment head over to Container Security on Cloud One and navigate to the policy. The Policy ID is the part after the last `/` in the URL: <https://cloudone.trendmicro.com/container/policies/relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured><br>Here: `relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured`
- `Cloud One region name`: Set your Cloud One region here if it is not `trend-us-1`.
- `Cloud One API Key`: Your Cloud One API Key with full access. This is mandatory.

### Section: Integrations Configuration

Set/update:

- `EKS Calico`: Enable/disable the most used Pod network on your EKS cluster. It's currently disabled by default but will come shortly
- `EKS Prometheus & Grafana`: Enable/disable Prometheus. It is an open-source systems monitoring and alerting toolkit integrated with a preconfigured Grafana.
- `EKS Trivy`: Enable/disable Trivy vulnerability scanning for comparison.

### Section: Deep Security

Set/update:

- `Deep Security`: Enable or disable the Deep Security deployment. If set to `false` Deep Security configuration will be skipped.
- `Deep Security License`: Your Deep Security license key.
- `Deep Security Username`: Username of the MasterAdmin.
- `Deep Security Password`: Password of the MasterAdmin.

Now, continue with the chapter [General Life-Cycle](life-cycle.md).