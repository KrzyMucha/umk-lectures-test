terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}
# Artifact Registry dla obrazów Docker
resource "google_artifact_registry_repository" "symphony_crud" {
  repository_id = "symphony-crud"
  location      = var.region
  format        = "DOCKER"
  description   = "Docker repository for symphony-crud application"
}

# Cloud Run Service
resource "google_cloud_run_v2_service" "symphony_crud" {
  name     = var.service_name
  location = var.region
  deletion_protection = false

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.symphony_crud.repository_id}/${var.service_name}:latest"

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
        startup_cpu_boost = true
      }

      env {
        name  = "APP_ENV"
        value = "prod"
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [google_artifact_registry_repository.symphony_crud]
}

# Zezwól na publiczny dostęp (unauthenticated)
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.symphony_crud.location
  name     = google_cloud_run_v2_service.symphony_crud.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
# Note: This is a skeleton for future Cloud Run deployment
# Will be implemented in the next step with Cloud SQL integration

# Placeholder for future resources:
# - google_cloud_run_v2_service
# - google_sql_database_instance
# - google_sql_database
# - google_secret_manager_secret (for DATABASE_URL)
