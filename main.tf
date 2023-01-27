terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
  }
}

locals {
  match_labels = merge({
    "app.kubernetes.io/name"     = "terraboard"
    "app.kubernetes.io/instance" = "terraboard"
  }, var.match_labels)
  labels = merge(local.match_labels, var.labels)
}

resource "kubernetes_deployment" "terraboard" {
  metadata {
    name      = "terraboard"
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    replicas = 1
    selector {
      match_labels = local.labels
    }
    template {
      metadata {
        labels = local.labels
        annotations = {
          "ravianand.me/config-hash" = sha1(jsonencode(merge(
            kubernetes_secret.terraboard.data
          )))
        }
      }
      spec {
        container {
          image = var.image_registry == "" ? "${var.image_repository}:${var.image_tag}" : "${var.image_registry}/${var.image_repository}:${var.image_tag}"
          name  = var.container_name
          args  = ["-c", "/config.yaml", "-p", "9090"]
          port {
            name           = "http"
            container_port = 9090
          }
          port {
            name           = "docs"
            container_port = 8081
          }
          volume_mount {
            name       = "config"
            mount_path = "/config.yaml"
            sub_path   = "config.yaml"
          }
        }
        volume {
          name = "config"
          secret {
            secret_name = kubernetes_service.terraboard.metadata.0.name
            items {
              key  = "config.yaml"
              path = "config.yaml"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "terraboard" {
  metadata {
    name      = var.service_name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    type     = var.service_type
    selector = local.match_labels
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }
  }
}

resource "kubernetes_service" "terraboard_docs" {
  metadata {
    name      = "terraboard-docs"
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    type     = var.service_type
    selector = local.match_labels
    port {
      name        = "http"
      port        = 8081
      target_port = "docs"
    }
  }
}

resource "kubernetes_secret" "terraboard" {
  metadata {
    name      = "terraboard"
    namespace = var.namespace
  }
  data = {
    "config.yaml" = yamlencode(var.config)
  }
}
