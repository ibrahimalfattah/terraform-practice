locals {
  frontend_repo_name = "${var.project_name}-frontend"
  backend_repo_name  = "${var.project_name}-backend"
}

resource "aws_ecr_repository" "frontend" {
  name = local.frontend_repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = merge(var.tags, {
    Name = local.frontend_repo_name
  })
}

resource "aws_ecr_repository" "backend" {
  name = local.backend_repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = merge(var.tags, {
    Name = local.backend_repo_name
  })
}

