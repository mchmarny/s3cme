# Description: Outputs for the deployment

output "REG_URI" {
  value       = "${google_artifact_registry_repository.registry.location}-docker.pkg.dev/${data.google_project.project.name}/${google_artifact_registry_repository.registry.name}"
  description = "Fully qualified Artifact Registry URI to use in Auth Actions."
}

output "IMG_NAME" {
  value       = google_artifact_registry_repository.registry.name
  description = "Image name to use in Auth Actions."
}

output "SA_EMAIL" {
  value       = google_service_account.github_actions_user.email
  description = "Service account to use in GitHub Actions."
}

output "PROVIDER_ID" {
  value       = google_iam_workload_identity_pool_provider.github_provider.name
  description = "Provider ID to use in Auth Actions."
}