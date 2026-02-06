provider "aws" {
  region = var.region
}

locals {
  cluster_name = "infradots-eks-${var.environment}"
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6"

  name = "infradots-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Required by EKS for proper load balancing discovery
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

################################################################################
# EKS Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.15"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    infradots_nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"
    }
  }

  # Cluster Access Entry (New EKS Access method)
  enable_cluster_creator_admin_permissions = true
}

################################################################################
# Route53
################################################################################

resource "aws_route53_zone" "this" {
  name = var.domain_name
}

################################################################################
# IRSA Roles (IAM for Service Accounts)
################################################################################

module "cert_manager_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 6.4"

  role_name                     = "cert-manager"
  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = [aws_route53_zone.this.arn]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }
}

module "external_dns_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 6.4"

  role_name                     = "external-dns"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = [aws_route53_zone.this.arn]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }
}

################################################################################
# EKS Addons
################################################################################

resource "aws_eks_addon" "cert_manager" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "cert-manager"
  service_account_role_arn = module.cert_manager_irsa_role.iam_role_arn
  
  # Ensure the addon is preserve on deletion if needed, currently sticking to terraform defaults
  depends_on = [module.eks]
}

resource "aws_eks_addon" "external_dns" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "external-dns"
  service_account_role_arn = module.external_dns_irsa_role.iam_role_arn

  configuration_values = jsonencode({
    domainFilters = [var.domain_name]
    policy        = "sync"
    registry      = "txt"
    txtOwnerId    = module.eks.cluster_name
  })

  depends_on = [module.eks]
}
