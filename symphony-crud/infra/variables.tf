variable "project" {
  description = "GCP project ID (from global)"
  type        = string
}

variable "region" {
  description = "GCP region (from global)"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
  default     = "symphony-crud"
}
