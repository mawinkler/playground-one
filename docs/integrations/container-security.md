# Vision One Container Security

> ***Note:*** At the time of writing, Container Security is integrated in Playground One by the helm chart on EKS only. The UI is still on Cloud One.

## Setup of Container Security with the Playground One

Container Security is automatically deployed to the EKS cluster of Playground One. If you provided a proper Cloud One information it is already up and running.

Required information in `config.yaml`:

- Trend Cloud One API Key
- Trend Cloud One Region
- Container Security Policy ID

To get the Policy ID head over to Container Security on Cloud One and navigate to the policy. The Policy ID is the part after the last `/` in the URL:

```ascii
https://cloudone.trendmicro.com/container/policies/relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured
```

Here: `relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured`

Relevant sections in `config.yaml` with example values:

```yaml
services:
  - name: cloudone
    ## Cloud One region to work with
    ## 
    ## Default value: trend-us-1
    region: us-1

    ## Cloud One instance to use
    ##
    ## Allowed values: cloudone, staging-cloudone, dev-cloudone
    ## 
    ## Default value: cloudone
    instance: cloudone

    ## Cloud One API Key with Full Access
    ## 
    ## REQUIRED if you want to play with Cloud One
    ##
    ## Default value: ''
    api_key: tmc1234567890...

- name: container_security
    ## The id of the policy for use with AWSONE
    ## 
    ## Default value: ''
    policy_id: relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured

...
```

## Scenarios

- [Escape to the Host System](../scenarios/container-security-eks-escape.md)

TODO

- [Gain a Privileged Shell](../scenarios/container-security-eks-privileged-shell.md)
- [Generate Runtime Violations](../scenarios/container-security-eks-runtime-violations.md)
- [Find Runtime Vulnerabilities](../scenarios/container-security-eks-runtime-vulnerability.md)
- ...
