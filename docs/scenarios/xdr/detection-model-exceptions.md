# Scenario: Detection Model Exceptions

***Draft***

!!! warning "UNVERIFIED"

    Useful, when you don't want to set namespace exclusions in Container Security but
    don't want OATs/Workbenches generated for know as-designed behavior.

## Prerequisites

- Playground One EKS EC2 or Fargate Cluster
- Vision One Container Security
- Playground One Scenarios

Ensure to have the EKS EC2 or Fargate Cluster including the Scenarios up and running:

```sh
# EC2 only
pgo --apply eks-ec2
```

## Vision One Container Security Overrides

## Detection Model Exception for Calico

Calico creates two violations against the runtime rule `TM-0000031` by the containers `flexvol-driver` and `csi-node-driver-registrar`. This is by design and can be excluded with the exception below:

![alt text](images/detection-model-exceptions-01.png "Calico")

## Detection Model Exception for Istio

The deployment of Istio contains a CNI which runs as a privileged pod. This is by design and can be excluded with the exception below:

![alt text](images/detection-model-exceptions-02.png "Istio")
