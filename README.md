# Playground One

Ultra fast and slim playground in the clouds designed for educational and demoing purposes.

In a nutshell:

- Bootstrapping directly from the clouds.

  ```sh
  curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/pgoc | bash

  ssh -p 2222 pgo@localhost
  # password: pgo
  ```

- Management of the environment with the help of an easy to use command line interface `pgo`.
- Based on Terraform >1.5

The Playground One has a modular structure and supports the following services:

*AWS*

Component         | Operational | Vision One Cloud Security
----------------- | ----------- | ----------------------------------------------------------------
EC2 Linux         | Yes         | V1 Server & Workload Protection<br>ASRM
EC2 Windows       | Yes         | V1 Server & Workload Protection
EKS EC2           | Yes         | V1CS Runtime Scanning<br>V1CS Runtime Security<br>OAT&WB Generation
EKS Fargate       | Yes         | V1CS Runtime Scanning<br>V1CS Runtime Security<br>OAT&WB Generation
Calico            | Yes         | EKS EC2 only
Prometheus        | Yes         | EKS EC2 only
Trivy             | Yes         | EKS EC2 only
ECS EC2           | Yes         | V1CS Runtime Scanning<br>V1CS Runtime Security
ECS Fargate       | Yes         | V1CS Runtime Scanning<br>V1CS Runtime Security
Deep Security     | Yes         | V1 Server & Workload Protection

*Azure*

Component         | Operational | Vision One Cloud Security
----------------- | ----------- | ----------------------------------------------------------------
AKS               | In progress | V1CS Runtime Scanning<br>V1CS Runtime Security

*Other*

Component         | Operational | Vision One Cloud Security
----------------- | ----------- | ----------------------------------------------------------------
TMAS              | Yes         | Artifact Scanning for Vulnerabilities and Malware
TMFS              | Yes         | File and Directory Scanning for Malware
Workload Security | Yes         | V1 Server & Workload Protection
Kind Kubernetes   | In progress |

***Documentation***

Please read and follow the documentation: ***[Playground One Pages](https://mawinkler.github.io/playground-one-pages/)***

## Support

This is an Open Source community project. Project contributors may be able to help, depending on their time and availability. Please be specific about what you're trying to do, your system, and steps to reproduce the problem.

For bug reports or feature requests, please [open an issue](../../issues). You are welcome to [contribute](#contribute).

Official support from Trend Micro is not available. Individual contributors may be Trend Micro employees, but are not official support.

## Contribute

I do accept contributions from the community. To submit changes:

1. Fork this repository.
1. Create a new feature branch.
1. Make your changes.
1. Submit a pull request with an explanation of your changes or additions.

I will review and work with you to release the code.
