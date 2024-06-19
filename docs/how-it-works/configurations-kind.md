# Playground One Kind Configurations

The Playground One has a modular structure as shown in the following tree:

```
kindone
└── kind (4-cluster-kind)
    ├── kind-deployments (8-cluster-kind-deployments)
    └── scenarios (7-scenarios-kind)
```

The following chapters describe the different configurations on a high level, refer the the dedicated documentation for more details.

## Kind Cluster

*Configuration located in `kindone/4-cluster-kind`*

Useful for quickly testing out Kubernetes things :-).

### Cluster Deployments

*Configuration located in `kindone/8-cluster-kind-deployments`*

*Depends on `kindone/4-cluster-kind`*

Currently, the following deployments are defined:

- Container Security
- Calico
- Prometheus & Grafana
- Trivy

### Scenarios

*Configuration located in `kindone/7-scenarios-kind`*

*Depends on `kindone/4-cluster-kind`*

Currently, the following (vulnerable) deployments are defined:

- Nginx

Automated attacks are running every full hour.
