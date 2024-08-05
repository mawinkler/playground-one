# Istio on EKS

Run your containerized workloads and microservices as part of a service-mesh 
with Istio on EKS! 🚀 

Istio plays a crucial role in enhancing and simplifying microservices-based 
application architectures by providing a powerful and comprehensive service mesh 
solution. Istio abstracts away many of the networking and security complexities 
in microservices-based applications, allowing developers to focus on business 
logic and application functionality. It provides a unified and robust platform 
for managing microservices at scale, improving reliability, security, and 
observability in the modern distributed application landscape. 

This repository, organized in modules, will guide you step-by-step in setting 
Istio on EKS and working with the most commonly observed service-mesh use cases.

## Modules 

#### [Getting Started](modules/01-getting-started/README.md)
#### [Traffic Management](modules/02-traffic-management/README.md)
#### [Network Resiliency](modules/03-network-resiliency/README.md)
#### [Security](modules/04-security/README.md)

## Patterns

#### [Multi-Primary, Multi-Network](patterns/multi-cluster-multinetwork-multiprimary/README.md)
#### [Spiffe/Spire Federation between EKS clusters](patterns/eks-istio-mesh-spire-federation/README.md)

## Terraform Modules

#### [Sidecar Istio deployment](terraform-blueprint/sidecar/README.md)
#### [Ambient Istio deployment](terraform-blueprint/ambient/README.md)

## Contributions
See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License
This library is licensed under the Apache 2.0 License.

## 🙌 Community
We welcome all individuals who are enthusiastic about Service Mesh and Istio patterns to become a part of this open source community. Your contributions and participation are invaluable to the success of this project.

Built with ❤️ at AWS.
