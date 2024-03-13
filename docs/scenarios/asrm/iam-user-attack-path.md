# Scenario: ASRM to detect Potential Attack Path to RDS via IAM User

***DRAFT***

## Prerequisites

- AWS Cloud Account integrated with Vision One

Ensure to have the Playground One Network up and running:

```sh
# Network configuration
pgo --apply network
```

## Setup

The Playground One configuration for EC2 (`ec2` or `instances`) can create an IAM User and IAM User Group with RDS Full Access and some EC2 action permissions when the creation of Potential Attack Path(s) is enabled in the config tool. The one of interest is the user `dbadmin` within the group dbadmins.

Verify, that you have `Vision One ASRM - create Potential Attack Path(s)` enabled in your configuration.

```sh
pgo --config
```

```sh
...
Vision One ASRM - create Potential Attack Path(s) [true]:
...
```

```sh
# With Potential Attack Path enabled
pgo --apply instances
```

The IAM User is detected by Vision One ASRM after some time when you configured your CAM stack properly. The full analysis which should lead to a potential attack path as seen in the below screenshot can take up to 48hs.

![alt text](images/asrm-iam-attack-path-01.png "Attack Path")

Below the Asset Graph of the high risk instance:

![alt text](images/asrm-iam-attack-path-02.png "Asset Graph")

🎉 Success 🎉

## Tear Down

At minimum, disable `Vision One ASRM - create Potential Attack Path(s)` in your configuration.

```sh
pgo --config
```

```sh
...
Vision One ASRM - create Potential Attack Path(s) [true]: false
...
```

```sh
pgo --apply instances
```
