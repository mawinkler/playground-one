# Scenario: Vision One Container Security Generate Runtime Violations

## Prerequisites

- Playground One EKS Cluster
- Vision One Container Security
- Playground One Scenarios

Ensure to have the EKS Cluster including the Scenarios up and running:

```sh
pgo --apply eks
pgo --apply scenarios
```

## Disclaimer

> ***Note:*** It is highly recommended to have the `awsone.access_ip` set to a single IP or at least a small CIDR before deploying the EKS cluster. This will prevent anonymous users playing with your environmnent. Remember: we're using vulnerable apps.

## Overview

Automated malicious actions are executed every full hour on your cluster which lead to detections in Container Security.

## The story

There is no real story here :-)

## Goals

Review the detection in Vision One.
