output "alb_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller IRSA role"
  value       = aws_iam_role.alb_controller.arn
}

output "external_secrets_role_arn" {
  description = "IAM role ARN for the External Secrets Operator IRSA role"
  value       = aws_iam_role.external_secrets.arn
}

