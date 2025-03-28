# Playground One

!!! success

    Hello dear Playground One fan. Nice that you found the documentation.

Ultra fast and slim playground in the clouds designed for educational and demoing purposes.

!!! abstract "Abstract"

    Playground Ones main purpose is to act as a learning platform and demo environment while ensuring a reproducible experience. Playground One itself is containerized and uses Terraform to manage the cloud lifecycle using an easy-to-use command line interface. It integrates with various services such as container clusters, virtual instances, storage, but also with the corresponding Vision One services and endpoints. Among other things, you can gain experience and present Vision One Container Security, File Security, XDR, ASRM, Operations, Server & Workload Protection, and APIs in real environments.

    Playground One includes scenarios and walkthroughs to help you expand your knowledge of cloud security. So if you've ever wanted to experiment with ECS security, run container image scans with GitHub Actions, use EKS with Fargate, do some nasty things, or drive successful demos, go and play with Playground One.

In a nutshell:

- Bootstrapping directly from the clouds.

  ```sh
  curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/get_pgoc.sh | bash
  ```

- Playground One is containerized and supports any `arm64`  or `amd64` based container engine.
- Alternatively, you can install natively on your system.
- Management of the environment with the help of an easy to use command line interface `pgo`.
- Based on Terraform >1.6

!!! danger "Under construction!"

    The Playground One is continuously under construction!
    The capabilities and contents are therefore to be enjoyed with caution and can change at any time.

## Requirements

The Playground One is designed to work on these platforms:

Playground One Container:

- Container engine hosted either on `arm64` or `amd64`.
- Tested with Docker and Colima on Ubuntu, Cloud9, MacOS Intel and Apple Silicon.

Playground One native installation:

- Ubuntu Bionic and newer.
- Intel and M1+ MacOS.

## System Health

### AWS

Component            | Operational | Known Issues | Vision One
-------------------- | ----------- | ------------ | -------------------
Network              | Yes         | See 1)       | Service Gateway<br>Identity Security<br>Virtual Network Sensor<br>Deep Discovery Inspector
Instances            | Yes         | None         | Server & Workload Protection<br>ASRM<br>Service Gateway<br>Identity Security<br>Virtual Network Sensor<br>Deep Discovery Inspector
EKS EC2              | Yes         | None         | Container Security<br>OAT&WB Generation<br>Terraform Provider<br>KSPM
EKS Fargate          | Yes         | None         | Container Security<br>OAT&WB Generation<br>Terraform Provider<br>KSPM
ECS EC2              | Yes         | See 2)       | Container Security
ECS Fargate          | Yes         | See 3)       | Container Security
Bucket Scanner       | Yes         |              | FSS SDK
Scenarios CloudTrail | Yes         |              | CloudTrail
Scenarios CSPM       | Yes         |              | CSPM
Scenarios Identity   | Yes         |              | Identity Security
Scenarios Zero Trust | Yes         |              | Zero Trust<br>Private Access Gateway
Deep Security        | Yes         | None         | Deep Security Integration & Migration<br>XDR<br>Server & Workload Protection
Workload Security    | Yes         | None         | Workload Security Integration & Migration<br>XDR<br>Server & Workload Protection

1) In addition to the network itself the following services can be enabled: Active Directory, AWS Managed Active Directory, Service Gateway, Virtual Network Sensor, and Deep Discovery Inspector. The Active Directories are pretty basic but support SSL. They will support additional scenarios with Identity Security, Data Security, and more.

2) Deleting the cluster requires the deactivation runtime scanning and runtime security before destroying the cluster. If destroy process `module.ecs-ec2[0].module.ecs_service.aws_ecs_service.this[0]: Still destroying...` hangs for a couple of minutes manually terminate the autoscaling group `pgo4-ecs-ec2-asg-spot-...` in AWS.

3) Activating Runtime Security requires some manual steps, see [documentation](https://docs.trendmicro.com/en-us/enterprise/trend-vision-one/cloudsecurityoperati/about-container-secu/next-steps/containerinventory/ecs-fargate-deployme/ecs-fargate-add.aspx). Deleting the cluster requires the deactivation of runtime scanning and runtime security before destroying the cluster. Newly created task definitions must be removed manually.

### Azure

Component         | Operational | Known Issues | Vision One Cloud Security
----------------- | ----------- | ------------ | ----------------------------------------------------------------
AKS               | Yes         | None         | Container Security

### Other

Component         | Operational | Known Issues | Vision One Cloud Security
----------------- | ----------- | ------------ | ----------------------------------------------------------------
TMAS              | Yes         | None         | Artifact Scanning for Vulnerabilities and Malware
TMFS              | Yes         | None         | File and Directory Scanning for Malware
Kind Kubernetes   | Yes         | Only native  |

## CLI Commands of the Playground

Besides the obvious cli tools like `kubectl`, etc. the Playground offers you additional commands shown in the table below (and more):

Area | Command | Function
---- | ------- | --------
PGO  | pgo | The command line interface for Playground One.
PGO  | pgoc | Starts, stops or updates the Playground One Container.
PGO  | pgos | Starts a new bash with AWS credentials of PGO User.
PGO  | dsm | Start or stop a deployed Deep Security.
Kubernetes  | kubie | See [github.com/sbstp/kubie](https://github.com/sbstp/kubie?tab=readme-ov-file#usage).
Kubernetes  | stern | Tail logs from multiple pods simultaneously.
Kubernetes  | k9s | See [k9scli.io](https://k9scli.io/).
Kubernetes  | k8s-ns-finalizer | Removes finalizer from namespace. Helpful when a namespace cannot be destroyed.
Kubernetes  | k8s-list-images | Lists and counts all unique images by namespace currently in use.
Vision One | tmcli-update | Update TMAS and TMFS to the latest version.
Vision One | ecsfg-add-v1cs | Patches ECS Fargate Task to activate Container Security.
Vision One | collect-logs | Collects logs and configuration of Container Security. Usage: `RELEASE=container-security collect-logs`.
AWS  | aws-cleanup-policies | Removes unattached policies of your PGO environment.
Vulnerabilities | syft | See [github.com/anchore/syft](https://github.com/anchore/syft).
Vulnerabilities | grype | See [github.com/anchore/grype](https://github.com/anchore/grype).

## Change Log

***0.4.10***

- Introduced Sandbox Analysis with Bucket Scanner.
- Introducing PGOWeb for eks-ec2 and kind clusters.
- Fixed MetalLB and Contour on Kind cluster.

***0.4.9***

- Introduced Kubernetes Metrics Server for EKS EC2 (`kubectl top pods...`).
- Added support for Vision One Container Security Policy Operator.
- New tools for C1 Conformita and Vision One Posture Management added.

***0.4.8***

*Changes*

- Bump Kubernetes on AWS to 1.31
- Upgrade Vision One Terraform provider to 1.0.4
- Enable Runtime Malware Scanning in V1CS

***0.4.7***

*Changes*

- New integration: Deep Discovery Inspector

***0.4.6***

*Changes*

- New scenario: Zero Trust Access - Lab

***0.4.5***

*Changes*

- Kind cluster now uses Terraform Provider for Container Security

***0.4.4***

*Changes*

- Update FSS SDK and improve Bucket Scanner Lambda sample

***0.4.3***

*Fixes*

- Fix `pgoc` on arm64
- Update documentation for PGO user initial setup
- Update default `group_id` for Container Security on EKS clusters

***0.4.2***

*Changes*

- Added support for Vision One Virtual Network Sensor. If enabled the Virtual Network Sensor is deployed into the PGO VPC. The PGO Active Directory and PGO instances will mirror their traffic to the data port of VNS. Requires the VNS Token from Vision One UI.
- Added support for Istio on EKS EC2.
- New Scenarios:
  - `XDR -> Detection Model Exceptions for Container Security`.
  - `Endpoint Security -> Deep Security -> Integrate Deep Security with Vision One and Demo Benefits`.
  - `Cloud Security -> Container Security -> EKS -> Playing with Istio Service Mesh`.
- You can now choose the OS SKU for the nodes in the AKS Cluster. It defaults to `AzureLinux`.
- The EKS cluster deployment of V1 Container Security now supports `group_id` using the Terraform Provider.
- The `pgo` command now checks if your local IP has changed and needs and update.

***0.4.1***

*Changes*

- AWS ECS configurations are now split into two separate configurations `ecs-ec2` and `ecs-fg`. This simplifies the deployment and now works the same way as AWS EKS.
- All Terraform Modules and Providers are now version fixed.
- Improved Naming of instances in regards to the PGO Active Directory
- `pgo --config` does now allow to disable initialization of Terraform after a first run. This speeds up configuration changes dramatically.
- Playground One can optionally use its own AWS user with limited privileges. The user can be created by running `pgo --apply user`, which of course requires administrative privileges with your own AWS user. You have to enable the PGO user in the configuration, but you can disable it at any time.
- Migrated EKS cluster deployments to use the [Vision One Terraform Provider](https://github.com/trendmicro/terraform-provider-vision-one/tree/main). 
- There are new scenarios available:
  - [Deploy Service Gateway on AWS manually](https://mawinkler.github.io/playground-one-pages/scenarios/vision-one/v1-aws-service-gateway-manually/)
  - [Deploy Service Gateway on AWS automatically](https://mawinkler.github.io/playground-one-pages/scenarios/vision-one/v1-aws-service-gateway-automatically/)
  - [Integrate an Active Directory via Service Gateway on AWS](scenarios/automation/service-gateway/v1-integrate-active-directory.md)
- New Scenario section: Workflow and Automation - Third-Party Integration:
  - [Setup Splunk](scenarios/automation/thirdparty/splunk-setup.md)
  - [Integrate Splunk with Vision One XDR](scenarios/automation/thirdparty/splunk-integrate-vision-one-xdr.md)
  - [Integrate V1CS Customer Runtime Security Rules with Splunk](scenarios/automation/thirdparty/splunk-integrate-vision-one-custom-rules.md)
  - [Setup Elastic Stack](scenarios/automation/thirdparty/elastic-stack.md)
  - [Integrate Elastic Stack with Vision One](scenarios/automation/thirdparty/elastic-stack-vision-one.md)
- XDR Threat Investigation: [CloudTrail](scenarios/xdr/cloudtrail.md)
- Identity Posture: [Populate the Active Directory](scenarios/identity-security/identity-posture/populate-ad.md)

***0.3.3***

*New*

- The network configuration can now optionally create an Active Directory (the PGO-style) within the VPC. Plan is to support Identity Security scenarios in the future. This is cheaper than the AWS Managed Active Directory.

***0.3.2***

*New*

- The network configuration can now optionally create an AWS Managed Active Directory within the VPC. Plan is to support Identity Security scenarios in the future.
- The same configuration can now optionally deploy a Vision One Service Gateway to the public subnet.

*Fixes*

- The deployment of Vision Container Security did use an incorrect API call when creating the cluster. Instead of `resourceId` the key `arn` from the old beta API was used.

***0.3.1***

*New*

- Cloud One Conformity Exception Workflows inspired by customer
- New Scenario section: Big Data
    - [Setup Splunk](https://mawinkler.github.io/playground-one-pages/scenarios/bigdata/splunk-setup/)
    - [Integrate Vision One with Splunk](https://mawinkler.github.io/playground-one-pages/scenarios/bigdata/splunk-integrate-vision-one-xdr/)
    - [Integrate V1CS Customer Runtime Security Rules with Splunk](https://mawinkler.github.io/playground-one-pages/scenarios/bigdata/splunk-integrate-vision-one-custom-rules/)

*Changes*

- Kind cluster now supports Workbench and OAT generation

***0.3.0***

*Changes*

- Migrated V1CS api to v3.0.

***0.2.9***

*Changes*

- Bump EKS module to version 20.8.5
- Reworked IAM for EKS-EC2 to not use am AWS admin account. Proper access permissions implemented. Minor IAM changes in EKS-FG.

***0.2.8 (04/19/2024)***

*Fixes*

- Resize file system now detects root volume device name.

***0.2.7 (04/04/2024)***

*Fixes*

- Fix in pgo cli to support Vision One Regions.
- Azure App Gateway functional with Java-Goof app of scenarios.

***0.2.6 (04/03/2024)***

*Fixes*

- Various fixes and compatibility changes for Product Experience and Deep Security Migration Scenario.
- Playground One now supports all Vision One Regions when interacting with the REST API.
- App Gateway now functional on AKS cluster. Ingress for Scenarios to be done.

*Changes*

- Bump version of DSM to 20.0.893

***0.2.5 (03/21/2024)***

Playground One is now included in Trend Micro Product Experience.

*Changes*

- Enabled EC2 Instance Connect via Console to EC2 instances for some regions. See [FAQ](https://mawinkler.github.io/playground-one-pages/faq/).
- Playground One is now able to run on Trend Micro Platform Experience. Ensure to enable it in the configuration.
- Deep Security now has SOAP API enabled.
- Upgraded Deep Security Manager and Agents to versions as of 03/18/2023.
- Added dryrun capability for apply and destroy in CLI.

***0.2.4 (03/13/2024)***

*Changes*

- The preparation for potential attack path detections with ASRM can now be enabled or disabled via the config tool.
- IAM User Potential Attack Path with a new [scenario](https://mawinkler.github.io/playground-one-pages/scenarios/asrm/iam-user-attack-path/).

***0.2.3 Fix release (03/08/2024)***

*Fixes*

- Corrected lock handling on network.

***0.2.2 (03/07/2024)***

*Fixes*

- `ecsfg-add-v1cs` does now work within the Playground One Container.

*Changes*

- AWS and Azure now use the same environment name.
- Local Kind cluster now supports load balancing and ingress controller based on Contour-Envoy.

***0.2.1 Fix release (02/27/2024)***

*Fixes*

- The implementation of a proper Vision One Container Security life-cycle broke the deployment since the DELETE api_call was fired too early.

*Changes*

- Simple S3 Bucket scanner now part of Playground One. This includes a dedicated [scenario](https://mawinkler.github.io/playground-one-pages/scenarios/as/tmfs-s3-bucket-scanning/).
- Improved handling of public IPs in configflow when running on Cloud9.
- Any existing Azure credentials will now be made available within the container.

***0.2 Maintenance release (02/20/2024)***

*Fixes*

- Vision One Container Security gets unregistered from Vision One on cluster destroy.
- Cluster deployments are now correctly destroyed in the correct order.
- Allow docker client to work with docker.sock on Cloud9

*Changes*

- Playground One Container now supports versioning.
- ECS Fargate task definition patcher bumped to version 2.3.30
- New scenario added: [Container Image Vulnerability and Malware Scanning as GitHub Action](https://mawinkler.github.io/playground-one-pages/scenarios/as/tmas-github-action/).
- Removed openssl3 demo app.

***0.1 Initial release (02/06/2024)***

## Support

This is an Open Source community project. Project contributors may be able to help, depending on their time and availability. Please be specific about what you're trying to do, your system, and steps to reproduce the problem.

For bug reports or feature requests, please [open an issue](https://github.com/mawinkler/playground-one/issues). You are welcome to [contribute](#contribute).

Official support from Trend Micro is not available. Individual contributors may be Trend Micro employees, but are not official support.

## Contribute

I do accept contributions from the community. To submit changes:

1. Fork this repository.
1. Create a new feature branch.
1. Make your changes.
1. Submit a pull request with an explanation of your changes or additions.

I will review and work with you to release the code.
