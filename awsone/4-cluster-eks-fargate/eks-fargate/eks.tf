# #############################################################################
# Create an EKS Cluster
# #############################################################################
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.2"

  cluster_name    = "${var.environment}-eks-fg-${random_string.suffix.result}"
  cluster_version = local.kubernetes_version

  # cluster_endpoint_private_access      = true
  cluster_endpoint_public_access = true
  # cluster_endpoint_public_access_cidrs = var.access_ip

  cluster_addons = {
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.intra_subnets

  # enable_irsa = true

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  fargate_profiles = merge(
    {
      default = {
        name = "default"
        selectors = [
          {
            namespace = "fargate"
          },
          {
            namespace = "default"
            # labels = {
            #   workertype = "fargate"
            # }
          },
        ]

        timeouts = {
          create = "20m"
          delete = "20m"
        }
      }
    },
    {
      trendmicro = {
        name = "trendmicro"
        selectors = [
          {
            namespace = "trendmicro-system"
          },
        ]
        timeouts = {
          create = "20m"
          delete = "20m"
        }
      }
    },
    { for i in range(1) :
      "kube-system-${element(split("-", local.azs[i]), 2)}" => {
        selectors = [
          { namespace = "kube-system" }
        ]
        # We want to create a profile per AZ for high availability
        subnet_ids = [element(var.private_subnets, i)]
      }
    }
  )

  eks_managed_node_groups = {
    "${var.environment}-node" = {
      min_size     = 1
      max_size     = 10
      desired_size = 2
      key_name     = "${var.key_name}"

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      labels = {
        Name        = "${var.environment}-eks"
        Environment = "${var.environment}"
      }
      taints = {
      }
      tags = {
        Name          = "${var.environment}-eks-node-group"
        Environment   = "${var.environment}"
        Product       = "playground-one"
        Configuration = "eks-fg"
      }
    }
  }

  tags = {
    Name          = "${var.environment}-eks"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "eks-fg"
  }
}

# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2009
data "aws_eks_cluster" "eks" {
  depends_on = [
    module.eks.eks_managed_node_groups
  ]
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  depends_on = [
    module.eks.eks_managed_node_groups
  ]
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.id]
    command     = "aws"
  }
}
