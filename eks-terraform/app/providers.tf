// Provider configurations for AWS, Kubernetes, and Helm

provider "aws" {
  region = var.aws_region
}

// EKS cluster data source used by Kubernetes and Helm providers
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

// Kubernetes provider configured against the EKS cluster using aws eks get-token
provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

// Helm provider (uses local kubeconfig / environment to reach the same cluster)
provider "helm" {
  alias = "eks"
}

