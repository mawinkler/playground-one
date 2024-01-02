# Versions as of 12/14/2024

**Terraform >=1.6**

## Terraform Providers

Provider | Link | Version | Used in
-------- | ---- | ------- | -------
AWS | https://registry.terraform.io/providers/hashicorp/aws | 5.30.0 | all
Cloudinit | https://registry.terraform.io/providers/hashicorp/cloudinit | 2.3.3 | ec2, eks-ec2, eks-fg
Helm | https://registry.terraform.io/providers/hashicorp/helm | 2.12.1 | eks-ec2, eks-fg
Kubernetes | https://registry.terraform.io/providers/hashicorp/kubernetes | 2.24.0 | nw, eks-ec2, eks-fg, ecs
Local | https://registry.terraform.io/providers/hashicorp/local | 2.4.1 | nw, eks-ec2, eks-fg, kind, dsm
Random | https://registry.terraform.io/providers/hashicorp/random | 3.6.0 | nw, ec2, eks-ec2, eks-fg
RestAPI | https://registry.terraform.io/providers/Mastercard/restapi | 1.18.2 | eks-ec2, eks-fg, dsw
Template | https://registry.terraform.io/providers/hashicorp/template | 2.2.0 | ec2, eks-ec2, eks-fg, dsm, dsw
Time | https://registry.terraform.io/providers/hashicorp/time | 0.10.0 | dsw
TLS | https://registry.terraform.io/providers/hashicorp/tls | 4.0.5 | all

## Terraform Modules

Module | Link | Version | Latest | Used in
------ | ---- | ------- | ------ | -------
AWS ALB | https://registry.terraform.io/modules/terraform-aws-modules/alb/aws | ~> 8.0 | 9.2.0 | ecs
AWS Autoscaling | https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws | ~> 7.3 | 7.3.1 | ecs
AWS ECS | https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws | 5.7.3 | 5.7.3 | ecs
AWS EKS | https://registry.terraform.io/modules/terraform-aws-modules/eks/aws | 19.21.0 | 19.21.0 | eks-ec2, eks-fg
AWS IAM | https://registry.terraform.io/modules/terraform-aws-modules/iam/aws | 5.32.1 | 5.32.1 | eks-ec2
AWS RDS | https://registry.terraform.io/modules/terraform-aws-modules/rds/aws | 6.3.0 | 6.3.0 | ec2, dsm
AWS Security Group | https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws | ~> 4.0 | 5.1.0 | ecs

## Kubernetes & Helm Charts

**Kubernetes Control Plane: 1.28**

Chart | Link | Version | Used in
----- | ---- | ------- | -------
Autoscaler | https://kubernetes.github.io/autoscaler | 9.34.0 | eks-ec2, ecs
Calico | https://docs.tigera.io/calico/charts/tigera-operator | 3.25.0 | eks-ec2
Load Balancer Controller | https://aws.github.io/eks-charts/aws-load-balancer-controller | latest | eks-ec2
Prometheus & Grafana | https://prometheus-community.github.io/helm-charts/kube-prometheus-stack | latest | eks-ec2
Trivy | https://aquasecurity.github.io/helm-charts/trivy-operator | latest | eks-ec2
Vision One Container Security | https://github.com/trendmicro/cloudone-container-security-helm | latest | eks-ec2, eks-fg
