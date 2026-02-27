locals {
  db_identifier = "${var.project_name}-postgres"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-subnets"
  })
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for PostgreSQL database"
  vpc_id      = var.vpc_id

  ingress {
    description      = "PostgreSQL from EKS nodes"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [var.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-sg"
  })
}

resource "random_password" "db" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}/db/password"

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-password"
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({ password = random_password.db.result })
}

resource "aws_db_instance" "this" {
  identifier = local.db_identifier

  engine            = "postgres"
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  username          = var.db_username
  password          = random_password.db.result
  db_name           = var.db_name
  port              = 5432

  allocated_storage      = 20
  storage_encrypted      = true
  backup_retention_period = 7

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true

  deletion_protection = false

  tags = merge(var.tags, {
    Name = local.db_identifier
  })
}

