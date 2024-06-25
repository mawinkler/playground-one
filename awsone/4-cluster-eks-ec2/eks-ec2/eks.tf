# #############################################################################
# EKS Cluster
# #############################################################################
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.14.0"

  cluster_name    = "${var.environment}-eks-ec2-${random_string.suffix.result}"
  cluster_version = local.kubernetes_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  # cluster_endpoint_public_access_cidrs = var.access_ip

  enable_cluster_creator_admin_permissions = true

  # Enable EFA support by adding necessary security group rules
  # to the shared node security group
  # enable_efa_support = true

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.intra_subnets

  enable_irsa = true

  # kms_key_aliases = ["${var.environment}-eks-ec2-${random_string.suffix.result}"]
  kms_key_deletion_window_in_days = 7

  cluster_addons = {
    coredns = {
      most_recent = true

      timeouts = {
        create = "2m" # default 20m. Times out on first launch while being effectively created
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  access_entries = {
    "${var.environment}-cluster-access" = {
      kubernetes_groups = []
      principal_arn     = aws_iam_role.this.arn

      policy_associations = {
        namespaced = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
        cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                              = "AL2_x86_64"
    cluster_additional_security_group_ids = [var.private_security_group_id]
    disk_size                             = 50
    instance_types                        = ["t3.medium", "t3.large"]
    vpc_security_group_ids                = [var.private_security_group_id]
  }

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

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
        Configuration = "eks-ec2"
      }
    }
  }

  tags = {
    Name          = "${var.environment}-eks"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "eks-ec2"
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
