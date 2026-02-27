output "db_endpoint" {
  description = "Endpoint of the PostgreSQL database"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Port of the PostgreSQL database"
  value       = aws_db_instance.this.port
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret storing the DB password"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "db_secret_name" {
  description = "Name of the Secrets Manager secret storing the DB password"
  value       = aws_secretsmanager_secret.db_password.name
}

output "db_username" {
  description = "Database master username"
  value       = var.db_username
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}

