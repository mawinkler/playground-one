# Playground One

Ultra fast and slim playground in the clouds designed for educational and demoing purposes.

!!! danger "Under construction!"

    Hello dear Playground One fan. Nice that you found the documentation.
    This is currently under construction!
    The contents are therefore to be enjoyed with caution and can still change at any time.

## Latest News

!!! ***Playground integrated with Vision One*** !!!

In a nutshell:

- Bootstrapping directly from the clouds.

  ```sh
  curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/pgoc | bash

  ssh -p 2222 pgo@localhost
  # password: pgo
  ```

- Management of the environment with the help of an easy to use command line interface `pgo`.
- Based on Terraform >1.5

## Change Log

02/01/2024

- Playground One in a Box - The Playground One Container<br>
  The Playgrond One Container allows you to use the playground on any container engine hosted either on `arm64` or `amd64` from within a containerized environment not affecting your system.

01/23/2024

- Playground One starts to support Intel and M1+ MacOS as host platform.

01/16/2024

- Playground One starts to support AKS and V1CS on Azure.

12/19/2023

- Automated Vision One Container Security deployment with EKS EC2 and Fargate Profiles.

11/14/2023

- Deep Security integrated for use in migration scenarios.

10/27/2023

- EKS Fargate & EKS Calico on EC2 operational.

10/10/2023

- Playground One goes public.

08/07/2023

- Initial release.

## Requirements

The Playground One is designed to work with AWS and is tested these operating systems:

- Ubuntu Bionic and newer
- Cloud9 with Ubuntu
- Intel and M1+ MacOS (likely older versions as well)

## System Health

### AWS

Component         | Operational | Known Issues | Vision One Cloud Security
----------------- | ----------- | ------------ | ----------------------------------------------------------------
EC2 Linux         | Yes         | None         | V1 Server & Workload Protection<br>ASRM
EC2 Windows       | Yes         | None         | V1 Server & Workload Protection
EKS EC2           | Yes         | None         | V1CS Runtime Scanning<br>V1CS Runtime Security<br>OAT&WB Generation
EKS Fargate       | Yes         | None         | V1CS Runtime Scanning<br>V1CS Runtime Security<br>OAT&WB Generation
ECS EC2           | Yes         | See 1)       | V1CS Runtime Scanning<br>V1CS Runtime Security
ECS Fargate       | Yes         | See 2)       | V1CS Runtime Scanning<br>V1CS Runtime Security
Calico            | Yes         | EKS EC2 only |
Prometheus        | Yes         | EKS EC2 only |
Trivy             | Yes         | EKS EC2 only |
Deep Security     | Yes         | None         | V1 Server & Workload Protection

1) Deleting the cluster requires the deactivation runtime scanning and runtime security before destroying the cluster. If destroy process `module.ecs-ec2[0].module.ecs_service.aws_ecs_service.this[0]: Still destroying...` hangs for a couple of minutes manually terminate the autoscaling group `pgo4-ecs-ec2-asg-spot-...` in AWS.

2) Activating Runtime Security requires some manual steps, see [documentation](https://docs.trendmicro.com/en-us/enterprise/trend-vision-one/cloudsecurityoperati/about-container-secu/next-steps/containerinventory/ecs-fargate-deployme/ecs-fargate-add.aspx). Deleting the cluster requires the deactivation of runtime scanning and runtime security before destroying the cluster. Newly created task definitions must be removed manually.

### Azure

Component         | Operational | Known Issues | Vision One Cloud Security
----------------- | ----------- | ------------ | ----------------------------------------------------------------
AKS               | In progress | None         | V1CS Runtime Scanning<br>V1CS Runtime Security

### Other

Component         | Operational | Known Issues | Vision One Cloud Security
----------------- | ----------- | ------------ | ----------------------------------------------------------------
TMAS              | Yes         | None         | Artifact Scanning for Vulnerabilities and Malware
TMFS              | Yes         | None         | File and Directory Scanning for Malware
Workload Security | Yes         | None         | V1 Server & Workload Protection
Kind Kubernetes   | In progress | None         |

## CLI Commands of the Playground

Besides the obvious cli tools like `kubectl`, etc. the Playground offers you additional commands shown in the table below (and more):

Command | Function
------- | --------
pgo | The command line interface for Playground One
stern | Tail logs from multiple pods simultaneously
syft | See [github.com/anchore/syft](https://github.com/anchore/syft)
grype | See [github.com/anchore/grype](https://github.com/anchore/grype)
k9s | See [k9scli.io](https://k9scli.io/)

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
