output "function_name" {
  description = "Deployed Cloud Function name"
  value       = google_cloudfunctions_function.function.name
}

output "function_url" {
  description = "HTTPS trigger URL for the function"
  value       = google_cloudfunctions_function.function.https_trigger_url
}
