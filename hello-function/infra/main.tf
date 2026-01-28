terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

resource "google_project_service" "enable" {
  for_each = toset([
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "storage.googleapis.com"
  ])
  service = each.key
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "function_bucket" {
  name          = "${var.project}-functions-bucket-${random_id.bucket_suffix.hex}"
  location      = var.region
  force_destroy = true
}

data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../services"
  output_path = "${path.module}/build/function.zip"
}

resource "google_storage_bucket_object" "function_archive" {
  name   = "${var.function_name}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_zip.output_path
}

resource "google_service_account" "function_sa" {
  account_id   = "${replace(var.function_name, "-", "")}-sa"
  display_name = "Service Account for ${var.function_name}"
}

resource "google_cloudfunctions_function" "function" {
  name                  = var.function_name
  description           = "Hello World function deployed via Terraform"
  runtime               = var.runtime
  entry_point           = var.entry_point
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name
  service_account_email = google_service_account.function_sa.email

  trigger_http = true

  depends_on = [google_project_service.enable]
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project
  region         = var.region
  cloud_function = google_cloudfunctions_function.function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
