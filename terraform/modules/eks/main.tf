locals {
  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )

  control_plane_subnet_ids = length(var.control_plane_subnet_ids) > 0 ? var.control_plane_subnet_ids : var.private_subnet_ids

  cluster_addons = merge(
    {
      coredns = {
        most_recent = true
      }
      "kube-proxy" = {
        most_recent = true
      }
      "vpc-cni" = {
        most_recent = true
      }
    },
    var.ebs_csi_role_arn == null ? {
      "aws-ebs-csi-driver" = {
        most_recent = true
      }
      } : {
      "aws-ebs-csi-driver" = {
        most_recent              = true
        service_account_role_arn = var.ebs_csi_role_arn
      }
    }
  )
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_enabled_log_types       = var.cluster_enabled_log_types

  create_cloudwatch_log_group              = true
  cloudwatch_log_group_retention_in_days   = var.cloudwatch_log_retention_in_days
  enable_cluster_creator_admin_permissions = true

  enable_irsa = var.enable_irsa

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  control_plane_subnet_ids = local.control_plane_subnet_ids

  cluster_addons = local.cluster_addons

  # The managed node roles carry the EBS CSI managed policy so the add-on can
  # work on the first apply even before a dedicated IRSA role is wired in.
  eks_managed_node_group_defaults = {
    ami_type                              = var.node_ami_type
    disk_size                             = var.node_disk_size
    attach_cluster_primary_security_group = true

    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }

  eks_managed_node_groups = {
    ondemand = {
      name           = "${var.cluster_name}-ondemand"
      subnet_ids     = var.private_subnet_ids
      capacity_type  = "ON_DEMAND"
      instance_types = var.on_demand_instance_types

      min_size     = var.on_demand_min_size
      max_size     = var.on_demand_max_size
      desired_size = var.on_demand_desired_size

      labels = {
        lifecycle = "on-demand"
        workload  = "general"
      }

      tags = merge(
        local.common_tags,
        {
          "k8s.io/cluster-autoscaler/enabled"             = "true"
          "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
          NodeGroup                                       = "ondemand"
        }
      )
    }

    spot = {
      name           = "${var.cluster_name}-spot"
      subnet_ids     = var.private_subnet_ids
      capacity_type  = "SPOT"
      instance_types = var.spot_instance_types

      min_size     = var.spot_min_size
      max_size     = var.spot_max_size
      desired_size = var.spot_desired_size

      labels = {
        lifecycle = "spot"
        workload  = "burst"
      }

      tags = merge(
        local.common_tags,
        {
          "k8s.io/cluster-autoscaler/enabled"             = "true"
          "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
          NodeGroup                                       = "spot"
        }
      )
    }
  }

  tags = local.common_tags
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}
