data "aws_caller_identity" "current" {}

locals {
  oidc_provider_url = replace(var.oidc_issuer_url, "https://", "")
}

// OIDC provider for IRSA using the EKS cluster issuer URL
resource "aws_iam_openid_connect_provider" "this" {
  url = var.oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  // Root CA thumbprint for the OIDC provider used by EKS clusters
  thumbprint_list = [
    "9e99a48a9960b14926bb7f3b02e22da0afd10f1c"
  ]

  tags = var.tags
}

// IAM role for AWS Load Balancer Controller
resource "aws_iam_role" "alb_controller" {
  name = "${var.project_name}-alb-controller-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.this.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancerControllerPolicy"
}

// IAM role for External Secrets Operator
resource "aws_iam_role" "external_secrets" {
  name = "${var.project_name}-external-secrets-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.this.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "external_secrets_secretsmanager" {
  name        = "${var.project_name}-external-secrets-sm"
  description = "Allow External Secrets Operator to read project secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets_policy_attach" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets_secretsmanager.arn
}

