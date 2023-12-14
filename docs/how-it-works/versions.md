# Versions as of 12/14/2024

**Terraform >=1.6**

## Terraform Providers and Modules

Provider | Link | Version
-------- | ---- | -------
AWS | https://registry.terraform.io/providers/hashicorp/aws | 5.30.0
Cloudinit | https://registry.terraform.io/providers/hashicorp/cloudinit | 2.3.3
Helm | https://registry.terraform.io/providers/hashicorp/helm | 2.12.1
Kubernetes | https://registry.terraform.io/providers/hashicorp/kubernetes | 2.24.0
Local | https://registry.terraform.io/providers/hashicorp/local | 2.4.1
Random | https://registry.terraform.io/providers/hashicorp/random |3.6.0
Template | https://registry.terraform.io/providers/hashicorp/template | 2.2.0
Time | https://registry.terraform.io/providers/hashicorp/time | 0.10.0
TLS | https://registry.terraform.io/providers/hashicorp/tls | 4.0.5

Module | Link | Version | Latest | Used in
------ | ---- | ------- | ------ | -------
AWS Autoscaling | https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws | ~> 7.3 | 7.3.1 | ecs
AWS ECS | https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws | 5.7.3 | 5.7.3 | ecs
AWS EKS | https://registry.terraform.io/modules/terraform-aws-modules/eks/aws | 19.21.0 | 19.21.0 | eks-ec2, eks-fg
AWS IAM | https://registry.terraform.io/modules/terraform-aws-modules/iam/aws | 5.32.1 | 5.32.1 | eks-ec2
AWS Security Group | https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws | ~> 4.0 | 5.1.0 | ecs
AWS ALB | https://registry.terraform.io/modules/terraform-aws-modules/alb/aws | ~> 8.0 | 9.2.0 | ecs

## Kubernetes & Helm Charts

**Kubernetes Control Plane: 1.28**

Chart | Link | Version
----- | ---- | -------
Autoscaler | https://kubernetes.github.io/autoscaler | 9.34.0 (9.29.3)
