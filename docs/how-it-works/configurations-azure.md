# Playground One Azure Configurations

The Playground One has a modular structure as shown in the following tree:

```
azone
└── aks (4-cluster-aks)
    ├── aks-deployments (8-cluster-aks-deployments)
    └── scenarios (7-scenarios-aks)
```

The following chapters describe the different configurations on a high level, refer the the dedicated documentation for more details.

## AKS Cluster

*Configuration located in `azone/4-cluster-aks`*

This configuration creates a Fargate EKS cluster with some nice key features:

- Azure Application Gateway as a web traffic (OSI layer 7) load balancer.
- Autoscaling

### Cluster Deployments

*Configuration located in `azone/8-cluster-aks-deployments`*

*Depends on `azone/4-cluster-aks`*

Currently, the following deployments are defined:

- Container Security
- Calico
- Prometheus & Grafana
- Trivy

Automated attacks are running every full hour.

### Scenarios

*Configuration located in `azone/7-scenarios-aks`*

*Depends on `azone/4-cluster-aks`*

Currently, the following (vulnerable) deployments are defined:

- Java-Goof
- Nginx

Automated attacks are running every full hour.
