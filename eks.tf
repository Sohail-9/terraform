module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Let the module create a VPC optimized for EKS (production teams often manage VPC separately; adjust if needed)
  vpc_create     = true
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets

  # Managed node groups with autoscaling limits
  node_groups = {
    managed = {
      desired_capacity = var.node_desired_capacity
      min_capacity     = var.node_min_capacity
      max_capacity     = var.node_max_capacity
      instance_types   = [var.node_instance_type]
      key_name         = var.ssh_key_name != "" ? var.ssh_key_name : null
      additional_tags  = { Name = "${var.cluster_name}-node" }
    }
  }

  # Improve security and enable IRSA support
  manage_aws_auth      = true
  create_oidc_provider = true

  enable_irsa = true

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
