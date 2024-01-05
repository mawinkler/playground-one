# Playground One

Ultra fast and slim playground in the clouds designed for educational and demoing purposes.

In a nutshell:

- Bootstrapping directly from the clouds. It will attempt to upgrade already installed tools to the latest available version.  

  ```sh
  curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/pgo | bash && exit
  ```

- Management of the environment with the help of an easy to use command line interface `pgo`.
- Based on Terraform >1.5

The Playground One has a modular structure and supports the following services:

Component         | Operational | Vision One Cloud Security
----------------- | ----------- | ----------------------------------------------------------------
EC2 Linux         | Yes         | V1 Server & Workload Protection<br>ASRM
EC2 Windows       | Yes         | V1 Server & Workload Protection
EKS EC2           | Yes         | V1CS Runtime Scanning<br>V1CS Runtime Security<br>OAT&WB Generation
EKS Fargate       | Yes         | V1CS Runtime Scanning<br>V1CS Runtime Security<br>OAT&WB Generation
EKS Calico        | Yes         | EKS EC2 only
EKS Prometheus    | Yes         | EKS EC2 only
EKS Trivy         | Yes         | EKS EC2 only
ECS EC2           | Yes         | V1CS Runtime Scanning<br>V1CS Runtime Security
ECS Fargate       | Yes         | V1CS Runtime Scanning<br>V1CS Runtime Security
TMAS              | Yes         | Artifact Scanning for Vulnerabilities and Malware
Deep Security     | Yes         | V1 Server & Workload Protection
Workload Security | Yes         | V1 Server & Workload Protection

***Documentation***

Please read and follow the documentation: ***[Playground One Pages](https://mawinkler.github.io/playground-one-pages/)***
