# Vision One Container Security

> ***Note:*** At the time of writing, Container Security is integrated in Playground One by the helm chart on EKS only. The UI is still on Cloud One.

## Setup of Container Security with the Playground One

Container Security is automatically deployed to the EKS cluster of Playground One. If you provided a proper Cloud One information it is already up and running.

Required information in `config.yaml`:

- Trend Cloud One API Key
- Trend Cloud One Region
- Container Security Policy ID

Create the EKS cluster including Container Security by running

```sh
$ pgo --apply eks
```

## Scenarios

- [Escape to Node](../scenarios/container-security-eks-escape.md)
- [Gain a Privileged Shell](../scenarios/container-security-eks-privileged-shell.md)
- [Generate Runtime Violations](../scenarios/container-security-eks-runtime-violations.md)
- [Find Runtime Vulnerabilities](../scenarios/container-security-eks-runtime-vulnerability.md)
