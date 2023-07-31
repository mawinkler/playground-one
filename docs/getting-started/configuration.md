# Getting Started Configuration

If you didn't create a new shell, then do so now.

After bootstrapping you need to create a file called `config.yaml` to hold your specific configuration. Create this by running

```sh
cd ${ONEPATH}
cp config.yaml.sample config.yaml
```

and open it with your prefered editor.

The bare minimum to adapt are:

- `aws.account_id`
- `cloudone_api_key`

For the rest and especially the default values see below:

```yaml
services:
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

    ## Cloud One Scanner API Key
    ## 
    ## REQUIRED if you want to play with Artifac Scanning as a Service
    ##
    ## Default value: ''
    scanner_api_key: ''

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
    ## Default value: "playground-one"
    environment: "playground-one"

  - name: awsone
    ## Restrict access to AWS One
    ## 
    ## Default value: "0.0.0.0/0"
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

  - name: container_security
    ## The id of the policy for use with AWSONE
    ## 
    ## Default value: ''
    policy_id: ''

  - name: workload-security
    ## Cloud One Workload Security Tenant ID
    ## 
    ## REQUIRED if you want to play with Cloud One Workload Security
    ##
    ## Default value: ''
    ws_tenant_id: ''

    ## Cloud One Workload Security Token
    ## 
    ## REQUIRED if you want to play with Cloud One Workload Security
    ##
    ## Default value: ''
    ws_token: ''

    ## Cloud One Workload Security Linux Policy ID
    ## 
    ## REQUIRED if you want to play with Cloud One Workload Security
    ##
    ## Default value: 0
    ws_policy_id: 0
...
```

Now, continue with the chapter [General Life-Cycle](../life-cycle.md).