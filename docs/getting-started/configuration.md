# Getting Started Configuration

If you didn't create a new shell, then do so now.

After bootstrapping you need to create a file called `config.yaml` to hold your specific configuration. Create this by running

```sh
$ cd ${ONEPATH}
$ cp config.yaml.sample config.yaml
```

and open it with your prefered editor. The following chapters walk you through the config file.

## Section: aws

The first section you need to adapt is `services.aws`:

```yaml
# Default values for Playground One.
# This is a YAML-formatted file.
services:
  - name: aws
    ## The account id of your AWS account
    ## 
    ## Default value: ''
    account_id: ''

    ## The default AWS region to use
    ## 
    ## Default value: "eu-central-1"
    region: ''

    ## The default AWS environment name to use
    ## 
    ## IMPORTANT: The value MUST NOT be longer than 15 characters
    ##
    ## Default value: "playground-one"
    environment: ''
    ##        max ############### 15 characters
```

Set:

- `account_id`: The ID of your AWS subscription (just numbers no `-`).
- `region`: If you want to use another region as `eu-central-1`.
- `environment`: Your to be built environment name. It MUST NOT be longer than 15 characters.

## Section: awsone

You don't necessarily need to change anything here if you're satisfied with the defaults, but

> ***note:*** It is highly recommended to change the `awsone.access_ip` to a single IP or at least a small CIDR to prevent anonymous users playing with your environmnent. Remember: we're deploying vulnerable applications.

```yaml
  - name: awsone
    ## Restrict access to AWS One
    ## 
    ## To define multipe IPs/CIDRs do something like
    ## ["87.170.6.193/32","3.123.18.11/32"]
    ##
    ## Default value: ["0.0.0.0/0"]
    access_ip: ''

    instances:
      ## Create Linux instance(s)
      ## 
      ## Default value: true
      create_linux: true

      ## Create Windows instance(s)
      ## 
      ## Default value: true
      create_windows: true

    cluster-eks:
      ## Create Fargate Profile
      ## 
      ## Default value: true
      create_fargate_profile : true

    cluster-ecs:
      ## Create ECS Cluster with EC2
      ## 
      ## Default value: true
      create_ec2: true

      ## Create ECS Cluster with Fargate
      ## 
      ## Default value: true
      create_fargate: true
```

Set:

- `access_ip`:
  - If you're running on a local Ubuntu server (not Cloud9), get your public IP and set the value to `["<YOUR IP>/32"]`.
  - If you're working on a Cloud9, get your public IP from home AND from the Cloud9 instance. Set the value to `["<YOUR IP>/32","<YOUR CLOUD9 IP>/32"]`
- `instances`: The `ec2` configuration can create Linux and/or Windows instance(s). If you only want Linux, you can disable Windows by setting it to `false` (and vice versa).
- `cluster-eks`: If you don't want the Fargate profile on the EKS cluster you can disable it here by setting it to `false`.
- `cluster-ecs`: Here you can choose to have ECS cluster(s) with EC2 and/or Fargate instances.

> If your IP address has changed see [FAQ](../faq.md#my-ip-address-has-changed-and-i-cannot-access-my-apps-anymore).

## Section: cloudone

Container Security will move to Vision One but currently requires your Cloud One environment. With GA availability of Vision One Container Security the following will change.

```yaml
  - name: cloudone
    ## Cloud One region to work with
    ## 
    ## Default value: trend-us-1
    region: ''

    ## Cloud One instance to use
    ##
    ## Allowed values: cloudone, staging-cloudone, dev-cloudone
    ## 
    ## Default value: cloudone
    instance: ''

    ## Cloud One API Key with Full Access
    ## 
    ## REQUIRED if you want to play with Cloud One
    ##
    ## Default value: ''
    api_key: ''
```

Set:

- `region`: Set your Cloud One region here if it is not `trend-us-1`.
- `instance`: If you are using a staging or dev environment set it here.
- `api_key`: Your Cloud One API Key with full access.

## Section: container_security

To get the Policy ID for your Container Security deployment head over to Container Security on Cloud One and navigate to the policy. The Policy ID is the part after the last `/` in the URL:

```ascii
https://cloudone.trendmicro.com/container/policies/relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured
```

Here: `relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured`

```yaml
  - name: container_security
    ## The id of the policy for use with AWSONE
    ## 
    ## Default value: ''
    policy_id: ''
```

Set:

- `policy_id`: Set the policy ID or your policy here.

Now, continue with the chapter [General Life-Cycle](life-cycle.md).