variable "project" {
  description = "GCP project ID (from global)"
  type        = string
}

variable "region" {
  description = "GCP region (from global)"
  type        = string
  default     = "us-central1"
}

variable "function_name" {
  description = "Name of the Cloud Function"
  type        = string
  default     = "hello-world-function"
}

variable "runtime" {
  description = "Function runtime"
  type        = string
  default     = "python39"
}

variable "entry_point" {
  description = "Function entry point"
  type        = string
  default     = "hello_world"
}
