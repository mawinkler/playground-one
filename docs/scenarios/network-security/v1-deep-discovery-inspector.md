# Scenario: Deploying Deep Discovery Inspector on AWS

***Draft***

!!! warning "NOT FINISHED YET"

## Prerequisites

- Playground One Network
- Activated Marketplace AMI for Trend Deep Discovery Inspector BYOL
- A valid license key for Deep Discovery Inspector

You need to have activated the Trend Deep Discovery Inspector BYOL AMI in Marketplace once. To do this, on the AWS Console choose the service EC2 and navigate to `Images --> AMI Catalog`. Select the tab `AWS Marketplace AMIs` and seach for `Trend Micro Virtual Network Sensor`.

There should only be one AMI shown for your current region. Click on `[Select]` and `[Subscribe on instance launch]`. 

Now, check your Playground One configuration.

Verify, that you have `DDI - create Deep Discovery Inspector` enabled in your configuration.

```sh
pgo --config
```

```sh
...
DDI - create Deep Discovery Inspector? [true]: 
...
```

Ensure to have the Playground One Network up and running:

```sh
# Network configuration
pgo --apply network

# Instances configuration
pgo --apply instances
```

You will get some output generated, the DDI relevant section is shown below:

```sh
...
Outputs:
...
ddi_ami = "ami-0089a63d4c91694fc"
ddi_va_ip = "3.122.148.231"
ddi_va_pip_dataport = "10.0.4.45"
ddi_va_pip_managementport = "10.0.4.230"
ddi_va_traffic_mirror_filter_id = "tmf-0729a55b05120aedb"
ddi_va_traffic_mirror_target_id = "tmt-032ac48714893a91f"
...
```

Use `ddi_va_id` to connect from the Vision One console.

!!! info "Initial Authentication"

    The first time you authenticate to the DDI console, you will be asked for an administrator account. Use `admin/admin` for this.

## Test It
