# Playground One

Ultra fast and slim playground in the clouds designed for educational and demoing purposes.

In a nutshell:

- Bootstrapping directly from the clouds. It will attempt to upgrade already installed tools to the latest available version.  

  ```sh
  curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/pgo | bash && exit
  ```

- Management of the environment with the help of an easy to use command line interface `pgo`.
- Based on Terraform >1.5

The Playground One has a modular structure as shown in the following tree:

```
awsone
└── network (2-network)
    ├── ec2 (3-instances)
    ├── eks (4-cluster-eks)
    |   ├── eks-deployments (8-cluster-eks-deployments)
    |   └── scenarios (7-scenarios)
    └── ecs (5-cluster-ecs)
```

As we can see, the configuration `network` is the base for the other configurations. It creates the VPC, Subnets, Route Tables, Security Groups, etc. One can choose to only create the EKS cluster, or ECS cluster, or even the full stack. Everything will reside in the same VPC.

![alt text](docs/how-it-works/images/architecture.png "Architecture diagram")
*Architecture: Example environment name `pgo8`*

***Documentation***

Please read and follow the documentation: ***[Playground One Pages](https://mawinkler.github.io/playground-one-pages/)***
