// Root module wiring all submodules together

locals {
  // Base name prefix used for resource naming
  name_prefix = var.project_name

  // Common tags applied to AWS resources
  common_tags = {
    Project     = var.project_name
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

// VPC and networking
module "vpc" {
  source = "../modules/01-vpc"

  project_name        = var.project_name
  aws_region          = var.aws_region
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = local.common_tags
}

// ECR repositories for frontend and backend
module "ecr" {
  source = "../modules/02-ecr"

  project_name = var.project_name
  tags         = local.common_tags
}

// EKS cluster and managed node group
module "eks" {
  source = "../modules/03-eks"

  project_name        = var.project_name
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  cluster_version     = var.cluster_version
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size

  tags = local.common_tags
}

// IRSA roles and OIDC provider for ALB controller and External Secrets Operator
module "irsa" {
  source = "../modules/04-irsa"

  project_name     = var.project_name
  aws_region       = var.aws_region
  cluster_name     = module.eks.cluster_name
  oidc_issuer_url  = module.eks.oidc_issuer_url

  tags = local.common_tags
}

// RDS PostgreSQL instance and Secrets Manager integration
module "rds_postgres" {
  source = "../modules/05-rds-postgres"

  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  node_security_group_id = module.eks.node_security_group_id

  db_name          = var.db_name
  db_username      = var.db_username
  db_instance_class = var.db_instance_class

  tags = local.common_tags
}

// EKS addons installed via Helm: AWS Load Balancer Controller, External Secrets Operator, cert-manager
module "eks_addons" {
  source = "../modules/06-eks-addons"

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  cluster_name              = module.eks.cluster_name
  cluster_endpoint          = module.eks.cluster_endpoint
  cluster_ca                = module.eks.cluster_ca
  aws_region                = var.aws_region
  alb_controller_role_arn   = module.irsa.alb_controller_role_arn
  external_secrets_role_arn = module.irsa.external_secrets_role_arn

  tags = local.common_tags
}

// Kubernetes application resources: namespaces, ESO resources, Deployments, Services, Ingress, TLS
module "k8s_apps" {
  source = "../modules/07-k8s-apps"

  providers = {
    kubernetes = kubernetes.eks
  }

  project_name             = var.project_name
  aws_region               = var.aws_region
  frontend_repo_url        = module.ecr.frontend_repo_url
  backend_repo_url         = module.ecr.backend_repo_url
  frontend_image_tag       = var.frontend_image_tag
  backend_image_tag        = var.backend_image_tag
  frontend_container_port  = var.frontend_container_port
  backend_container_port   = var.backend_container_port
  backend_health_path      = var.backend_health_path

  db_endpoint    = module.rds_postgres.db_endpoint
  db_port        = module.rds_postgres.db_port
  db_username    = module.rds_postgres.db_username
  db_name        = module.rds_postgres.db_name
  db_secret_name = module.rds_postgres.db_secret_name

  app_domain = var.app_domain
  enable_tls = var.enable_tls
  acme_email = var.acme_email

  depends_on = [
    module.eks_addons
  ]
}

