# Getting Started Configuration

If you didn't create a new shell, then do so now.

Playground One is controlled by the command line interface `pgo`.

Use it to interact with the Playground One by running

```sh
pgo
```

from anywhere in your terminal.

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

Available configurations: vpc, nw, ec2, eks, ecs, scenarios

Main commands:
  -c --config   Set/update Playground One main configuration
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
  nw            Network configuration
  ec2           EC2 configuration
  eks           EKS configuration
  ecs           ECS configurations
  scenarios     Scenario configurations
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

Set/update:

- `AWS Account ID`: The ID of your AWS subscription (just numbers no `-`). This is mandatory.
- `AWS region name`: If you want to use another region as `eu-central-1`.
- `AWS environment name`: Your to be built environment name. It MUST NOT be longer than 15 characters.

### Section: Playground One

You don't necessarily need to change anything here if you're satisfied with the defaults, but

> ***note:*** It is highly recommended to change the `Access IPs/CIDRs` to (a) single IP(s) or at least a small CIDR to prevent anonymous users playing with your environmnent. Remember: we might deploy vulnerable applications.

Set/update:

- `Access IPs/CIDRs`:
  - If you're running on a local Ubuntu server (not Cloud9), get your public IP and set the value to `["<YOUR IP>/32"]`.
  - If you're working on a Cloud9, get your public IP from home AND from the Cloud9 instance. Set the value to `["<YOUR IP>/32","<YOUR CLOUD9 IP>/32"]`
- `EC2 - create Linux EC2`: Enable/disable Linux instances in the `ec2` configuration.
- `EC2 - create Windows EC2`: Enable/disable Windows instances in the `ec2` configuration.
- `EKS - create Fargate profile`: Enable/disable the Fargate profile on the EKS cluster.
- `ECS - utilize EC2 nodes`: Enable/disable ECS cluster with EC2 nodes.
- `ECS - utilize Fargate nodes`: Enable/disable ECS cluster with Fargate nodes.

> If your IP address has changed see [FAQ](../faq.md#my-ip-address-has-changed-and-i-cannot-access-my-apps-anymore).

### Section: Cloud One

Container Security will move to Vision One but currently requires your Cloud One environment. With GA availability of Vision One Container Security the following will change.

Set/update:

- `Cloud One region name`: Set your Cloud One region here if it is not `trend-us-1`.
- `Cloud One API Key`: Your Cloud One API Key with full access. This is mandatory.
- `Container Security policy ID`: To get the Policy ID for your Container Security deployment head over to Container Security on Cloud One and navigate to the policy. The Policy ID is the part after the last `/` in the URL: <https://cloudone.trendmicro.com/container/policies/relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured><br>Here: `relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured`

### Section: Vision One

Vision One Server & Workload Protection does support the deployment script functionality from Cloud One Workload Security. The ECS EC2 cluster can optionally deploy the agent using this mechanism. To enable this

Set/update:

- `Server & Workload Protection tenant ID`: The tenant ID to use
- `Server & Workload Protection token`: The token to use
- `Server & Workload Protection policy ID`: The policy to assign

Now, continue with the chapter [General Life-Cycle](life-cycle.md).