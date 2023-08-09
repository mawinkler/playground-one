# Vision One Container Security

> ***Note:*** At the time of writing, Container Security is integrated in Playground One by the helm chart on EKS only. The UI is still on Cloud One.

## Setup of Container Security with the Playground One

Container Security is automatically deployed to the EKS cluster of Playground One. If you provided a proper Cloud One information it is already up and running.

Required information:

- Trend Cloud One API Key
- Trend Cloud One Region

Optional information:

- Container Security Policy ID

To get the Policy ID head over to Container Security on Cloud One and navigate to the policy. The Policy ID is the part after the last `/` in the URL:

```ascii
https://cloudone.trendmicro.com/container/policies/relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured
```

Here: `relaxed_playground-2OxPQEiC6Jo4dbDVfebKiZMured`

If you don't configure a policy ID you'll need to assign one within the Cloud One console.

## Scenarios

- [Escape to the Host System](../scenarios/container-security-eks-escape.md)
- [ContainerD Abuse](../scenarios/container-security-eks-dind-exploitation.md)