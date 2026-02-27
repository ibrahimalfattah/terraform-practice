locals {
  app_namespace          = "${var.project_name}-app"
  db_configmap_name      = "db-config"
  db_secret_name_k8s     = "db-credentials"
  backend_app_name       = "backend"
  frontend_app_name      = "frontend"
  ingress_name           = "${var.project_name}-ingress"
  certificate_secret_name = "tls-${var.project_name}-app"
  clusterissuer_name     = "${var.project_name}-letsencrypt"
  clustersecretstore_name = "${var.project_name}-aws-secrets-store"
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = local.app_namespace
  }
}

// ClusterSecretStore pointing to AWS Secrets Manager
resource "kubernetes_manifest" "cluster_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = local.clustersecretstore_name
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.aws_region
        }
      }
    }
  }
}

// ExternalSecret to sync DB password into K8s Secret
resource "kubernetes_manifest" "db_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "db-password"
      namespace = local.app_namespace
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = local.clustersecretstore_name
      }
      target = {
        name           = local.db_secret_name_k8s
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "DB_PASSWORD"
          remoteRef = {
            key = var.db_secret_name
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.cluster_secret_store
  ]
}

// ConfigMap with DB connection parameters (except password)
resource "kubernetes_config_map" "db" {
  metadata {
    name      = local.db_configmap_name
    namespace = local.app_namespace
  }

  data = {
    DB_HOST = var.db_endpoint
    DB_PORT = tostring(var.db_port)
    DB_NAME = var.db_name
    DB_USER = var.db_username
  }
}

// Backend Deployment
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = local.backend_app_name
    namespace = local.app_namespace
    labels = {
      app = local.backend_app_name
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = local.backend_app_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.backend_app_name
        }
      }

      spec {
        container {
          name  = local.backend_app_name
          image = "${var.backend_repo_url}:${var.backend_image_tag}"

          port {
            container_port = var.backend_container_port
          }

          env {
            name = "DB_HOST"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.db.metadata[0].name
                key  = "DB_HOST"
              }
            }
          }

          env {
            name = "DB_PORT"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.db.metadata[0].name
                key  = "DB_PORT"
              }
            }
          }

          env {
            name = "DB_NAME"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.db.metadata[0].name
                key  = "DB_NAME"
              }
            }
          }

          env {
            name = "DB_USER"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.db.metadata[0].name
                key  = "DB_USER"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = local.db_secret_name_k8s
                key  = "DB_PASSWORD"
              }
            }
          }

          liveness_probe {
            http_get {
              path = var.backend_health_path
              port = var.backend_container_port
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = var.backend_health_path
              port = var.backend_container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_manifest.db_external_secret
  ]
}

// Backend Service
resource "kubernetes_service" "backend" {
  metadata {
    name      = "${local.backend_app_name}-svc"
    namespace = local.app_namespace
    labels = {
      app = local.backend_app_name
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = local.backend_app_name
    }

    port {
      port        = var.backend_container_port
      target_port = var.backend_container_port
    }
  }
}

// Frontend Deployment
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = local.frontend_app_name
    namespace = local.app_namespace
    labels = {
      app = local.frontend_app_name
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = local.frontend_app_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.frontend_app_name
        }
      }

      spec {
        container {
          name  = local.frontend_app_name
          image = "${var.frontend_repo_url}:${var.frontend_image_tag}"

          port {
            container_port = var.frontend_container_port
          }

          env {
            name  = "API_BASE_URL"
            value = "https://${var.app_domain}/api"
          }
        }
      }
    }
  }
}

// Frontend Service
resource "kubernetes_service" "frontend" {
  metadata {
    name      = "${local.frontend_app_name}-svc"
    namespace = local.app_namespace
    labels = {
      app = local.frontend_app_name
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = local.frontend_app_name
    }

    port {
      port        = var.frontend_container_port
      target_port = var.frontend_container_port
    }
  }
}

// Optional ClusterIssuer for Let's Encrypt (HTTP-01 via ALB)
resource "kubernetes_manifest" "cluster_issuer" {
  count = var.enable_tls ? 1 : 0

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = local.clusterissuer_name
    }
    spec = {
      acme = {
        email  = var.acme_email
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "${var.project_name}-acme-account-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "alb"
              }
            }
          }
        ]
      }
    }
  }
}

// Optional Certificate for the application domain
resource "kubernetes_manifest" "certificate" {
  count = var.enable_tls ? 1 : 0

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "${var.project_name}-certificate"
      namespace = local.app_namespace
    }
    spec = {
      secretName = local.certificate_secret_name
      dnsNames   = [var.app_domain]
      issuerRef = {
        name = local.clusterissuer_name
        kind = "ClusterIssuer"
      }
    }
  }

  depends_on = [
    kubernetes_manifest.cluster_issuer
  ]
}

// Ingress using AWS Load Balancer Controller (ALB)
resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = local.ingress_name
    namespace = local.app_namespace
    annotations = {
      "kubernetes.io/ingress.class"              = "alb"
      "alb.ingress.kubernetes.io/scheme"         = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"    = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path" = var.backend_health_path
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = var.app_domain
      http {
        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.frontend.metadata[0].name
              port {
                number = var.frontend_container_port
              }
            }
          }
        }

        path {
          path     = "/api"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.backend.metadata[0].name
              port {
                number = var.backend_container_port
              }
            }
          }
        }
      }
    }

    dynamic "tls" {
      for_each = var.enable_tls ? [1] : []

      content {
        hosts       = [var.app_domain]
        secret_name = local.certificate_secret_name
      }
    }
  }

  depends_on = [
    kubernetes_service.frontend,
    kubernetes_service.backend,
    kubernetes_manifest.certificate
  ]
}

