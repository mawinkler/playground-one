# Scenario: ASRM to detect Potential Attack Path

***DRAFT***

## Prerequisites

- AWS Cloud Account integrated with Vision One

Ensure to have the Playground One Network up and running:

```sh
# Network configuration
pgo --apply nw
```

## Setup

The Playground One configuration for EC2 (ec2 or instances) creates two Linux servers when enabled in the config tool. The one of interest here is the `db1` instance since it get's an instance profile assigned which allows database read access to RDS.

A (free-tier) PostgreSQL dabase is automatically created when applying the configuration. It is now actively used but required to have an endpoint of the potential attack path.

```sh
# With Linux machines enabled (verify with pgo --config)
pgo --apply ec2
```

The Linux instances are detected by Vision One ASRM after some time when you configured your CAM stack properly. The full analysis which should lead to a potential attack path for the `db1` instance as seen in the below screenshot can take up to 24hs.

![alt text](images/asrm-ec2-attack-path-01.png "Attack Path")

Below the Asset Graph of the high risk instance:

![alt text](images/asrm-ec2-attack-path-02.png "Asset Graph")

🎉 Success 🎉
